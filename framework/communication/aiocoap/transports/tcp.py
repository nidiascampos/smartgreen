# This file is part of the Python aiocoap library project.
#
# Copyright (c) 2012-2014 Maciej Wasilak <http://sixpinetrees.blogspot.com/>,
#               2013-2014 Christian Amsüss <c.amsuess@energyharvesting.at>
#
# aiocoap is free software, this file is published under the MIT license as
# described in the accompanying LICENSE file.

import asyncio

from aiocoap import COAP_PORT, Message
from aiocoap import interfaces, error, util
from aiocoap.numbers.codes import CSM, PING, PONG, RELEASE, ABORT

from communication.aiocoap import optiontypes


def _extract_message_size(data: bytes):
    """Read out the full length of a CoAP messsage represented by data.

    Returns None if data is too short to read the (full) length.

    The number returned is the number of bytes that has to be read into data to
    start reading the next message; it consists of a constant term, the token
    length and the extended length of options-plus-payload."""

    if not data:
        return None

    l = data[0] >> 4
    tokenoffset = 2
    tkl = data[0] & 0x0f

    if l >= 13:
        if l == 13:
            extlen = 1
            offset = 13
        elif l == 14:
            extlen = 2
            offset = 269
        else:
            extlen = 4
            offset = 65805
        if len(data) < extlen + 1:
            return None
        tokenoffset = 2 + extlen
        l = int.from_bytes(data[1:1 + extlen], "big") + offset
    return tokenoffset, tkl, l

def _decode_message(data: bytes) -> Message:
    tokenoffset, tkl, _ = _extract_message_size(data)
    if tkl > 8:
        raise error.UnparsableMessage("Overly long token")
    code = data[tokenoffset - 1]
    token = data[tokenoffset:tokenoffset + tkl]

    msg = Message(code=code, token=token)

    msg.payload = msg.opt.decode(data[tokenoffset + tkl:])

    return msg

def _encode_length(l: int):
    if l < 13:
        return (l, b"")
    elif l < 269:
        return (13, (l - 13).to_bytes(1, 'big'))
    elif l < 65805:
        return (14, (l - 269).to_bytes(2, 'big'))
    else:
        return (15, (l - 65805).to_bytes(4, 'big'))

def _serialize(msg: Message) -> bytes:
    data = [msg.opt.encode()]
    if msg.payload:
        data += [b'\xff', msg.payload]
    data = b"".join(data)
    l, extlen = _encode_length(len(data))

    tkl = len(msg.token)
    if tkl > 8:
        raise ValueError("Overly long token")

    return b"".join((
            bytes(((l << 4) | tkl,)),
            extlen,
            bytes((msg.code,)),
            msg.token,
            data
            ))

class TcpConnection(asyncio.Protocol, interfaces.EndpointAddress):
    # currently, both the protocol and the EndpointAddress are the same object.
    # if, at a later point in time, the keepaliving of TCP connections should
    # depend on whether the library user still keeps a usable address around,
    # those functions could be split.

    def __init__(self, ctx, log, loop, *, hostinfo=None):
        self._ctx = ctx
        self.log = log
        self.loop = loop

        self._spool = b""

        self._my_max_message_size = 1024 * 1024
        self._remote_settings = None

        self._transport = None
        self._hostinfo = hostinfo

    @property
    def scheme(self):
        return self._ctx._scheme

    def _send_initial_csm(self):
        my_csm = Message(code=CSM)
        # this is a tad awkward in construction because the options objects
        # were designed under the assumption that the option space is constant
        # for all message codes.
        block_length = optiontypes.UintOption(2, self._my_max_message_size)
        my_csm.opt.add_option(block_length)
        supports_block = optiontypes.UintOption(4, 0)
        my_csm.opt.add_option(supports_block)
        self._send_message(my_csm)

    def _process_signaling(self, msg):
        if msg.code == CSM:
            if self._remote_settings is None:
                self._remote_settings = {}
            for opt in msg.opt.option_list():
                # FIXME: this relies on the relevant option numbers to be
                # opaque; message parsing should already use the appropriate
                # option types, or re-think the way options are parsed
                if opt.number == 2:
                    self._remote_settings['max-message-size'] = int.from_bytes(opt.value, 'big')
                elif opt.number == 4:
                    self._remote_settings['block-wise-transfer'] = True
                elif opt.number.is_critical():
                    self.abort("Option not supported", bad_csm_option=opt.number)
                else:
                    pass # ignoring elective CSM options
        elif msg.code in (PING, PONG, RELEASE, ABORT):
            # not expecting data in any of them as long as Custody is not implemented
            for opt in msg.opt.option_list():
                if opt.number.is_critical():
                    self.abort("Unknown critical option")
                else:
                    pass

            if msg.code == PING:
                pong = Message(code=PONG, token=msg.token)
                self._send_message(pong)
            elif msg.code == PONG:
                pass
            elif msg.code == RELEASE:
                raise NotImplementedError
            elif msg.code == ABORT:
                raise NotImplementedError
        else:
            self.abort("Unknown signalling code")

    def _send_message(self, msg: Message):
        self.log.debug("Sending message: %r", msg)
        self._transport.write(_serialize(msg))

    def abort(self, errormessage=None, bad_csm_option=None):
        self.log.warning("Aborting connection: %s", errormessage)
        abort_msg = Message(code=ABORT)
        if errormessage is not None:
            abort_msg.payload = errormessage.encode('utf8')
        if bad_csm_option is not None:
            bad_csm_option_option = optiontypes.UintOption(2, bad_csm_option)
            abort_msg.opt.add_option(bad_csm_option_option)
        if self._transport is not None:
            self._send_message(abort_msg)
            self._transport.close()
        else:
            # FIXME: find out how this happens; i've only seen it after nmap
            # runs against an aiocoap server and then shutting it down.
            # "poisoning" the object to make sure this can not be exploited to
            # bypass the server shutdown.
            self._ctx = None

    # implementing asyncio.Protocol

    def connection_made(self, transport):
        self._transport = transport

        self._send_initial_csm()

    def connection_lost(self, exc):
        # FIXME react meaningfully:
        # * send event through pool so it can propagate the error to all
        #   requests on the same remote
        # * mark the address as erroneous so it won't be recognized by
        #   fill_or_recognize_remote

        self._ctx._dispatch_error(self, exc)

    def data_received(self, data):
        # A rope would be more efficient here, but the expected case is that
        # _spool is b"" and spool gets emptied soon -- most messages will just
        # fit in a single TCP package and not be nagled together.
        #
        # (If this does become a bottleneck, say self._spool = SomeRope(b"")
        # and barely change anything else).

        self._spool += data

        while True:
            msglen = _extract_message_size(self._spool)
            if msglen is None:
                break
            msglen = sum(msglen)
            if msglen > self._my_max_message_size:
                self.abort("Overly large message announced")
                return

            if msglen > len(self._spool):
                break

            msg = self._spool[:msglen]
            try:
                msg = _decode_message(msg)
            except error.UnparsableMessage:
                self.abort("Failed to parse message")
                return
            msg.remote = self

            self.log.debug("Received message: %r", msg)

            self._spool = self._spool[msglen:]

            if msg.code.is_signalling():
                self._process_signaling(msg)
                continue

            if self._remote_settings is None:
                self.abort("No CSM received")
                return

            self._ctx._dispatch_incoming(self, msg)

    def eof_received(self):
        # FIXME: as with connection_lost, but less noisy if announced
        # FIXME: return true and initiate own shutdown if that is what CoAP prescribes
        pass

    def pause_writing(self):
        # FIXME: do something ;-)
        pass

    def resume_writing(self):
        # FIXME: do something ;-)
        pass

    # implementing interfaces.EndpointAddress

    @property
    def hostinfo(self):
        if self._hostinfo:
            return self._hostinfo
        peername = self._transport.get_extra_info('peername')
        return util.hostportjoin(peername[0], peername[1])

    @property
    def hostinfo_local(self):
        # `host` already contains the interface identifier, so throwing away
        # scope and interface identifier
        host, port, *_ = self._transport.get_extra_info('socket').getsockname()
        if port == self._ctx._default_port:
            port = None
        return util.hostportjoin(host, port)

    is_multicast = False
    is_multicast_locally = False

    @property
    def uri_base(self):
        if self._hostinfo:
            return self._ctx._scheme + '://' + self.hostinfo
        else:
            raise error.AnonymousHost("Client side of %s can not be expressed as a URI" % self._ctx._scheme)

    @property
    def uri_base_local(self):
        if self._hostinfo:
            raise error.AnonymousHost("Client side of %s can not be expressed as a URI" % self._ctx._scheme)
        else:
            return self._ctx._scheme + '://' + self.hostinfo_local

    @property
    def maximum_block_size_exp(self):
        if self._remote_settings is None:
            # This is assuming that we can do BERT, so a first Block1 would be
            # exponent 7 but still only 1k -- because by the time we send this,
            # we typically haven't seen a CSM yet, so we'd be stuck with 6
            # because 7959 says we can't increase the exponent...
            #
            # FIXME: test whether we're properly using lower block sizes if
            # server says that szx=7 is not OK.
            return 7

        max_message_size = (self._remote_settings or {}).get('max-message-size', 1152)
        has_blockwise = (self._remote_settings or {}).get('block-wise-transfer', False)
        if max_message_size > 1152 and has_blockwise:
            return 7
        return 6 # FIXME: deal with smaller max-message-size

    @property
    def maximum_payload_size(self):
        max_message_size = (self._remote_settings or {}).get('max-message-size', 1152)
        has_blockwise = (self._remote_settings or {}).get('block-wise-transfer', False)
        if max_message_size > 1152 and has_blockwise:
            return ((max_message_size - 128) // 1024) * 1024
        return 1024 # FIXME: deal with smaller max-message-size

class _TCPPooling:
    # implementing TokenInterface

    def send_message(self, message, exchange_monitor=None):
        if message.code.is_response():
            no_response = (message.opt.no_response or 0) & (1 << message.code.class_ - 1) != 0
            if no_response:
                return

        message.remote._send_message(message)

    # used by the TcpConnection instances

    def _dispatch_incoming(self, connection, msg):
        if msg.code == 0:
            pass

        if msg.code.is_response():
            self._tokenmanager.process_response(msg)
            # ignoring the return value; unexpected responses can be the
            # asynchronous result of cancelled observations
        else:
            self._tokenmanager.process_request(msg)

    def _dispatch_error(self, connection, exc):
        self._evict_from_pool(connection)

        if self._tokenmanager is None:
            if exc is not None:
                self.log.warning("Ignoring late error during shutdown: %s", exc)
            else:
                # it's just a regular connection loss, that's to be expected during shutdown
                pass
            return

        if isinstance(exc, OSError):
            self._tokenmanager.dispatch_error(exc.errno, connection)
        else:
            self.log.info("Expressing incoming exception %r as errno 0", exc)
            self._tokenmanager.dispatch_error(0, connection)

    # for diverting behavior of _TLSMixIn
    _scheme = 'coap+tcp'
    _default_port = COAP_PORT

class TCPServer(_TCPPooling, interfaces.TokenInterface):
    def __init__(self):
        self._pool = set()

    @classmethod
    async def create_server(cls, bind, tman: interfaces.TokenManager, log, loop, *, _server_context=None):
        self = cls()
        self._tokenmanager = tman
        self.log = log
        #self.loop = loop

        bind = bind or ('::', None)
        bind = (bind[0], bind[1] + (self._default_port - COAP_PORT) if bind[1] else self._default_port)

        def new_connection():
            c = TcpConnection(self, log, loop)
            self._pool.add(c)
            return c

        server = await loop.create_server(new_connection, bind[0], bind[1],
                ssl=_server_context)
        self.server = server

        return self

    def _evict_from_pool(self, connection):
        self._pool.remove(connection)

    # implementing TokenInterface

    async def fill_or_recognize_remote(self, message):
        if message.remote is not None \
                and isinstance(message.remote, TcpConnection) \
                and message.remote._ctx is self:
            return True

        return False

    async def shutdown(self):
        self.server.close()
        for c in self._pool:
            # FIXME: it would be nicer to release them
            c.abort("Server shutdown")
        await self.server.wait_closed()
        self._tokenmanager = None

class TCPClient(_TCPPooling, interfaces.TokenInterface):
    def __init__(self):
        self._pool = {} # (host, port) -> connection
        # note that connections are filed by host name, so different names for
        # the same address might end up with different connections, which is
        # probably okay for TCP, and crucial for later work with TLS.

    async def _spawn_protocol(self, message):
        if message.unresolved_remote is None:
            host = message.opt.uri_host
            port = message.opt.uri_port or self._default_port
            if host is None:
                raise ValueError("No location found to send message to (neither in .opt.uri_host nor in .remote)")
        else:
            host, port = util.hostportsplit(message.unresolved_remote)
            port = port or self._default_port

        if (host, port) in self._pool:
            return self._pool[(host, port)]

        _, protocol = await self.loop.create_connection(
                lambda: TcpConnection(self, self.log, self.loop,
                                      hostinfo=util.hostportjoin(host, port)),
                host, port,
                ssl=self._ssl_context_factory())

        self._pool[(host, port)] = protocol

        return protocol

    # for diverting behavior of TLSClient
    def _ssl_context_factory(self):
        return None

    def _evict_from_pool(self, connection):
        keys = []
        for k, p in self._pool.items():
            if p is connection:
                keys.append(k)
        # should really be zero or one
        for k in keys:
            self._pool.pop(k)

    @classmethod
    async def create_client_transport(cls, tman: interfaces.TokenManager, log, loop):
        # this is not actually asynchronous, and even though the interface
        # between the context and the creation of interfaces is not fully
        # standardized, this stays in the other inferfaces' style.
        self = cls()
        self._tokenmanager = tman
        self.log = log
        self.loop = loop

        return self

    # implementing TokenInterface

    async def fill_or_recognize_remote(self, message):
        if message.remote is not None \
                and isinstance(message.remote, TcpConnection) \
                and message.remote._ctx is self:
            return True

        if message.requested_scheme == self._scheme:
            # FIXME: This could pool outgoing connections.
            # (Checking if an incoming connection is a pool candidate is
            # probably overkill because even if a URI can be constructed from a
            # ephemeral client port, nobody but us can use it, and we can just
            # set .remote).
            message.remote = await self._spawn_protocol(message)
            return True

        return False

    async def shutdown(self):
        for c in self._pool.values():
            # FIXME: it would be nicer to release them
            c.abort("Server shutdown")
        del self._tokenmanager
