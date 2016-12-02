import paho.mqtt.publish as publish
import os
from pymongo import MongoClient


def mongo_read():
    # sensors = ["01", "02", "03", "04"]
    sensors = ["01", "02"]
    depths = ["15", "45", "60"]
    payload = []
    for sensor in sensors:
        for depth in depths:
            item = collection.find({"sensor": sensor, "depth": depth}).sort("when", -1)
            sensor = item[0]['sensor']
            depth = item[0]['depth']
            average = item[0]['average']
            print('sensor: ', sensor)
            print('depth: ', depth)
            print('average: ', average)
            data = [sensor, depth, average]
            payload.append(data)

def gsm_connect():
    os.system('pon tim')


def gsm_disconnect():
    os.system('poff')


def publish_adafruit(adafruit_topic, adafruit_payload):

    adafruit_username = "andreibosco"
    adafruit_key = "f38fefdd1fa94e2aaec9fd857b036e19"

    # msgs = [(adafruit_username + "/f/WM_01_15", "13", 0, True),
    #         (adafruit_username + "/f/WM_01_45", "23", 0, True),
    #         (adafruit_username + "/f/WM_01_75", "33", 0, True),
    #         (adafruit_username + "/f/WM_01_VCC", "4.7", 0, True)]
    #
    # publish.multiple(msgs,
    #                  hostname="io.adafruit.com",
    #                  port=1883,
    #                  auth={'username': adafruit_username, 'password': adafruit_key}
    #                  )]

    publish.single(adafruit_username+"/f/"+adafruit_topic, adafruit_payload, qos=0, retain=True,
                   hostname="io.adafruit.com",
                   port=1883,
                   auth={'username': adafruit_username, 'password': adafruit_key}
                   )

    print("Published to adafruit")  # FIXME: Debug


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.teste05


# MQTT
# Paho python docs: https://eclipse.org/paho/clients/python/docs/
# client_mqtt = mqtt.Client()
# client_mqtt.on_connect = mqtt_connect
# client_mqtt.on_message = mqtt_message
# client_mqtt.connect("localhost", 1883, 60)
# client_mqtt.loop_forever()
mongo_read()