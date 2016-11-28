import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import os
import time
from pymongo import MongoClient


def mqtt_connect(client, userdata, rc):
    print("Connected with result: "+str(rc))
    client.subscribe("/#")


def mqtt_message(client, userdata, msg):
    print("Received message '" + str(msg.payload) + "' on topic '"
          + msg.topic + "' with QoS " + str(msg.qos))
    # splitting topic info
    topic_list = msg.topic.split('/')
    sensor_id = topic_list[1]
    sensor_depth = topic_list[2]
    if sensor_depth != '0':
        # splitting sensor data
        data_list = msg.payload.split(',')
        data_std = data_list.pop(21)
        data_average = data_list.pop(20)
        adafruit_topic = "WM_" + sensor_id + "_" + sensor_depth
        # sending data do mongodb
        mongo_add_message(sensor_id, sensor_depth, data_average, data_std, data_list)
    else:
        # splitting sensor data
        sensor_vcc = msg.payload
        adafruit_topic = "WM_" + sensor_id + "_VCC"
        # sending data do mongodb
        mongo_add_vcc(sensor_id, sensor_vcc)
    print(adafruit_topic)
    gsm_connect()
    time.sleep(10)
    publish_adafruit()
    time.sleep(10)
    gsm_disconnect()


def mongo_add_message(sensor_id, sensor_depth, data_average, data_std, data_list):
    import datetime
    # inserting data into mongodb
    db.teste04.insert({
        "sensor": sensor_id,
        "depth": sensor_depth,
        "when": datetime.datetime.utcnow(),
        "average": data_average,
        "STD": data_std,
        "raw": tuple(data_list)
    })


def mongo_add_vcc(sensor_id, sensor_vcc):
    import datetime
    db.teste04.insert({
        "sensor": sensor_id,
        "when": datetime.datetime.utcnow(),
        "vcc": sensor_vcc
    })


def publish_adafruit():  # FIXME: continuar...
    # if(msg.)

    adafruit_username = "andreibosco"
    adafruit_key = "f38fefdd1fa94e2aaec9fd857b036e19"

    msgs = [(adafruit_username + "/f/WM_01_15", "16", 0, True),
            (adafruit_username + "/f/WM_01_45", "26", 0, True),
            (adafruit_username + "/f/WM_01_75", "36", 0, True),
            (adafruit_username + "/f/WM_01_VCC", "6.9", 0, True)]

    publish.multiple(msgs,
                     hostname="io.adafruit.com",
                     port=1883,
                     auth={'username': adafruit_username, 'password': adafruit_key}
                     )
    print('publicado no adafruit')


def gsm_connect():
    os.system('pon tim')


def gsm_disconnect():
    os.system('poff')


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


# MQTT
# Paho python docs: https://eclipse.org/paho/clients/python/docs/
client_mqtt = mqtt.Client()
client_mqtt.on_connect = mqtt_connect
client_mqtt.on_message = mqtt_message
client_mqtt.connect("localhost", 1883, 60)
client_mqtt.loop_forever()
