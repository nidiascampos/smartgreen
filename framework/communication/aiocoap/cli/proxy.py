# This file is part of the Python aiocoap library project.
#
# Copyright (c) 2012-2014 Maciej Wasilak <http://sixpinetrees.blogspot.com/>,
#               2013-2014 Christian Amsüss <c.amsuess@energyharvesting.at>
#
# aiocoap is free software, this file is published under the MIT license as
# described in the accompanying LICENSE file.

"""a plain CoAP proxy that can work both as forward and as reverse proxy"""

import argparse
import sys

import aiocoap
from aiocoap.cli.common import add_server_arguments, server_context_from_arguments
from aiocoap.proxy.server import ForwardProxyWithPooledObservations, ReverseProxyWithPooledObservations, NameBasedVirtualHost, SubresourceVirtualHost, UnconditionalRedirector

from communication.aiocoap.util import AsyncCLIDaemon


def build_parser():
    p = argparse.ArgumentParser(description=__doc__)

    mode = p.add_argument_group("mode", "Required argument for setting the operation mode")
    mode.add_argument('--forward', help="Run as forward proxy", action='store_const', const=ForwardProxyWithPooledObservations, dest='direction')
    mode.add_argument('--reverse', help="Run as reverse proxy", action='store_const', const=ReverseProxyWithPooledObservations, dest='direction')

    details = p.add_argument_group("details", "Options that govern how requests go in and out")
    add_server_arguments(details)
    details.add_argument('--proxy', help="Relay outgoing requests through yet another proxy", metavar="HOST[:PORT]")

    r = p.add_argument_group('Rules', description="Sequence of forwarding rules that, if matched by a request, specify a forwarding destination")
    class TypedAppend(argparse.Action):
        def __call__(self, parser, namespace, values, option_string=None):
            if getattr(namespace, self.dest) is None:
                setattr(namespace, self.dest, [])
            getattr(namespace, self.dest).append((option_string, values))
    r.add_argument('--namebased', help="If Uri-Host matches NAME, route to DEST", metavar="NAME:DEST", action=TypedAppend, dest='r')
    r.add_argument('--pathbased', help="If a requested path starts with PATH, split that part off and route to DEST", metavar="PATH:DEST", action=TypedAppend, dest='r')
    r.add_argument('--unconditional', help="Route all requests not previously matched to DEST", metavar="DEST", action=TypedAppend, dest='r')

    return p

class Main(AsyncCLIDaemon):
    async def start(self, args=None):
        parser = build_parser()
        options = parser.parse_args(args if args is not None else sys.argv[1:])

        if options.direction is None:
            raise parser.error("Either --forward or --reverse must be given.")

        self.outgoing_context = await aiocoap.Context.create_client_context()
        proxy = options.direction(self.outgoing_context)
        for kind, data in options.r or ():
            if kind == '--namebased':
                try:
                    name, dest = data.split(':', 1)
                except:
                    raise parser.error("--namebased needs NAME:DEST as arguments")
                r = NameBasedVirtualHost(name, dest)
            elif kind == '--pathbased':
                try:
                    path, dest = data.split(':', 1)
                except:
                    raise parser.error("--pathbased needs PATH:DEST as arguments")
                r = SubresourceVirtualHost(path.split('/'), dest)
            elif kind == '--unconditional':
                r = UnconditionalRedirector(data)
            else:
                raise AssertionError('Unknown redirectory kind')
            proxy.add_redirector(r)

        self.proxy_context = await server_context_from_arguments(proxy, options)

    async def shutdown(self):
        await self.outgoing_context.shutdown()
        await self.proxy_context.shutdown()

sync_main = Main.sync_main

if __name__ == "__main__":
    # if you want to run this using `python3 -m`, see http://bugs.python.org/issue22480
    sync_main()
