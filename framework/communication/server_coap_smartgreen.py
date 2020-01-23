#!/usr/bin/env python3

# This file is part of the Python aiocoap library project.
#
# Copyright (c) 2012-2014 Maciej Wasilak <http://sixpinetrees.blogspot.com/>,
#               2013-2014 Christian Amsüss <c.amsuess@energyharvesting.at>
#
# aiocoap is free software, this file is published under the MIT license as
# described in the accompanying LICENSE file.

"""This is a usage example of aiocoap that demonstrates how to implement a
simple server. See the "Usage Examples" section in the aiocoap documentation
for some more information."""

import asyncio
import logging
import json
from datetime import datetime

from communication import aiocoap
from service import Storage as stor
import communication.aiocoap.resource as resource


class StoreMonitoringPointData(resource.Resource):
   def __init__(self, database):
        super(StoreMonitoringPointData,self).__init__()
        self.database = database

   async def render_put(self, request):
        date = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
        print('PUT payload: %s' % request.payload)
        c = request.payload
        content = str(c, 'utf-8')
        data = json.loads(content)

        moisture_data = data['matric_potential']


        for soil_layer_id in moisture_data.keys():
            #print("md-> field_id:{}, soil_layer_id:{}, mp_id:{}, value:{}".format(data['field_id'], int(soil_layer_id),
             #data['mp_id'], moisture_data[soil_layer_id]))
            self.database.insert_moisture_data( date, data['field_id'], int(soil_layer_id),
             data['mp_id'], moisture_data[soil_layer_id])

        #self.database.insert_monitoring_point_power_data(date,data['field_id'],data['mp_id'],data['power_level'])
        print("pd-> field_id:{}, mp_id:{}, value:{}".format(data['field_id'],data['mp_id'],data['power_level']))


        payload = ("BD updated").encode('utf8')

        return aiocoap.Message(code=aiocoap.CHANGED, payload=c)


# logging setup

logging.basicConfig(level=logging.INFO)
logging.getLogger("coap-server").setLevel(logging.DEBUG)

def main():
    # Resource tree creation
    root = resource.Site()

    root.add_resource(('.well-known', 'core'),
                      resource.WKCResource(root.get_resources_as_linkheader))

    database= stor.Storage('localhost', 'root', '12345678')

    root.add_resource(['store_monitoring_point_data'], StoreMonitoringPointData(database))

    asyncio.Task(aiocoap.Context.create_server_context(root))

    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
    main()
