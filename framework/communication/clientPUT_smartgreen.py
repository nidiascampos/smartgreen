#!/usr/bin/env python3

# This file is part of the Python aiocoap library project.
#
# Copyright (c) 2012-2014 Maciej Wasilak <http://sixpinetrees.blogspot.com/>,
#               2013-2014 Christian Amsüss <c.amsuess@energyharvesting.at>
#
# aiocoap is free software, this file is published under the MIT license as
# described in the accompanying LICENSE file.

"""This is a usage example of aiocoap that demonstrates how to implement a
simple client. See the "Usage Examples" section in the aiocoap documentation
for some more information."""

import asyncio
import logging

from communication.aiocoap import *

logging.basicConfig(level=logging.INFO)

async def main():
    """Perform a single PUT request to localhost on the default port, URI
    "/other/block". The request is sent 2 seconds after initialization.

    The payload is bigger than 1kB, and thus sent as several blocks."""

    context = await Context.create_client_context()

    await asyncio.sleep(2)



    #field_id -> idenficador do campo, neste caso sempre 1
    #monitoring_point_id -> identificador do nó sensor, entao varia de 1 a 4
    #L15 -> leirura do tensiomentro a 15 cm de profundidade
    # L45 -> leirura do tensiomentro a 45 cm de profundidade
    # L75 -> leirura do tensiomentro a 75 cm de profundidade
    #power_level -> nivel de energia do nó sensor

    payload = b"field_id:1;monitoring_point_id:1;L15:20.4567;L45:30.467;L75:50.345;power_level:50"
    #request = Message(code=PUT, payload=payload, uri="coap://200.129.43.208/field/coco/T1")
    request = Message(code=PUT, payload=payload, uri="coap://localhost/field/1/monitoring_point/1")

    response = await context.request(request).response

    print('Result: %s\n%r'%(response.code, response.payload))

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main())
