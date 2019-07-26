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

import communication.aiocoap.resource as resource
from communication import aiocoap
from service import Storage as stor


class MonitoringPoint(resource.Resource):
    """Example resource which supports the GET and PUT methods. It sends large
    responses, which trigger blockwise transfer."""

    def __init__(self, database):
        super(MonitoringPoint,self).__init__()
        self.database = database
        self.soil_layer_15=1
        self.soil_layer_45 =2
        self.soil_layer_75 =3

        #con.select_db('banco de dados')

    async def render_get(self, request):
        return aiocoap.Message(payload=self.content)

    async def render_put(self, request):
        print('PUT payload: %s' % request.payload)
        c = request.payload
        content = str(c, 'utf-8')
        info = content.split(";")
        values=[]

        print("Updating field monitoring point")
        for col in info:
            d=col.split(":")
            values.append(float(d[1]))


        data = dict(zip(['field_id', 'monitoring_point_id', 'L15', 'L45', 'L75', 'power_level'], values))

        self.database.insert_moisture_data(int(data['field_id']), self.soil_layer_15, int(data['monitoring_point_id']), data['L15'])
        self.database.insert_moisture_data(int(data['field_id']), self.soil_layer_45, int(data['monitoring_point_id']), data['L45'])
        self.database.insert_moisture_data(int(data['field_id']), self.soil_layer_75, int(data['monitoring_point_id']), data['L75'])
        self.database.insert_monitoring_point_power_data(int(data['field_id']), int(data['monitoring_point_id']), data['power_level'])


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
        
    root.add_resource(('field', '1', 'monitoring_point', '1'), MonitoringPoint(database))

    root.add_resource(('field', '1', 'monitoring_point', '2'), MonitoringPoint(database))

    root.add_resource(('field', '1', 'monitoring_point', '3'), MonitoringPoint(database))

    root.add_resource(('field', '1', 'monitoring_point', '4'), MonitoringPoint(database))


    asyncio.Task(aiocoap.Context.create_server_context(root))

    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
    main()
