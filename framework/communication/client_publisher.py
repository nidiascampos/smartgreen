#!/usr/bin/env python3

"""This is a usage example of Smart&Green Client that demonstrates how to send moisture at 15, 45 and 75 cm
and power level of monitoring point '1' at a field. The msg file structure must follow as
{'mp_id':1,'moisture':{'150':value1 ,'450':value2,'750':value3}, 'power_level':value4},
where '150', '450',
#MQTT Connection Return Codes
#0: Connection successful
#1: Connection refused – incorrect protocol version
#2: Connection refused – invalid client identifier
#3: Connection refused – server unavailable
#4: Connection refused – bad username or password
#5: Connection refused – not authorised

''"""

import asyncio
import logging
import json
import time

from communication.aiocoap import *
from communication.aiocoap.numbers.codes import Code
import sys, getopt

import communication.mqtt_client as mqtt

logging.basicConfig(level=logging.INFO)


async def main(argv):
    protocol=""
    config_file=""
    msg_file=""
    try:
        opts, args = getopt.getopt(argv, "hp:c:m:", ["protocol=","confile=", "msgfile="])
    except getopt.GetoptError:
        print('client_publisher.py -p <coap|mqtt> -c <configuration_file> -m <msg_file>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('client_publisher.py -p <coap|mqtt> -c <configuration_file> -m <msg_file>')
            sys.exit()
        elif opt in ("-p", "--protocol"):
            protocol=arg
            if protocol not in ("coap", "mqtt"):
                print("protocol must be coap or mqtt")
                sys.exit()
        elif opt in ("-c", "--confile"):
            config_file = arg
        elif opt in ("-m", "--msgfile"):
            msg_file = arg



    send_msg={}
    moisture_data={}
    m={}

    with open(msg_file) as json_msg_file:
        msg_data = json.load(json_msg_file)
        send_msg['mp_id']=msg_data['mp_id']
        send_msg['power_level']=msg_data['power_level']
        moisture_data = msg_data['matric_potential']

    with open(config_file) as json_config_file:
        config_data = json.load(json_config_file)
        send_msg['farm_id']=config_data['farm_id']
        send_msg['field_id']=config_data['field_id']

        soil_layer_ids = {}
        for info in config_data['mp_info']:
            if info['id']==send_msg['mp_id']:
                soil_layer_ids=info['soil_layer_ids']
                for depth_z in moisture_data.keys():
                    s_id=soil_layer_ids[depth_z]
                    m[s_id]=moisture_data[depth_z]

        send_msg['matric_potential']=m
        payload = json.dumps(send_msg).encode('utf-8')

        if protocol=='coap':
            context = await Context.create_client_context()
            server_address = "coap://"+config_data['coap_server_address']+"/store_monitoring_point_data"
            request = Message(code=Code.PUT, payload=payload, uri=server_address)
            response = await context.request(request).response
            print('Result: %s\n%r' % (response.code, response.payload))

        elif protocol=='mqtt':
            server_address=config_data['mqtt_server_address']
            client_name="field_id={}".format(send_msg['field_id'])
            client =  mqtt.MQTTClient(client_name)
            client.set_msg_data(payload)
            client.on_connect = mqtt.MQTTClient.on_connect
            client.on_publish= mqtt.MQTTClient.on_publish
            client.set_topic(config_data["mqtt_topic"])
            client.connect(server_address)
            client.loop_start()  # Start loop
            while not client.connected_flag:  # wait in loop
                print("mqtt client in wait loop")
                time.sleep(1)

            client.loop_stop()
            if client.bad_connection_flag:
                sys.exit(client.rc)







if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main(sys.argv[1:]))
