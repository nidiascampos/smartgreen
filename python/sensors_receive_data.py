import logging
import paho.mqtt.client as mqtt
from pymongo import MongoClient


def mqtt_connect(client, userdata, rc):
    logging.info("Connected with result: "+str(rc))
    client.subscribe("/#")


def mqtt_message(client, userdata, msg):
    logging.info("Received message '" + str(msg.payload) + "' on topic '"
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
        # sending data do mongodb
        mongo_add_message(sensor_id, sensor_depth, data_average, data_std, data_list)
    else:
        # splitting sensor data
        sensor_vcc = msg.payload
        # sending data do mongodb
        mongo_add_vcc(sensor_id, sensor_vcc)


def mongo_add_message(sensor_id, sensor_depth, data_average, data_std, data_list):
    import datetime
    # inserting data into mongodb
    db.teste05.insert({
        "sensor": sensor_id,
        "depth": sensor_depth,
        "when": datetime.datetime.utcnow(),
        "average": data_average,
        "STD": data_std,
        "raw": tuple(data_list)
    })


def mongo_add_vcc(sensor_id, sensor_vcc):
    import datetime
    db.teste05.insert({
        "sensor": sensor_id,
        "when": datetime.datetime.utcnow(),
        "vcc": sensor_vcc
    })


# Basic config
logging.basicConfig(filename="/home/pi/logs/sensors_receive_data.log", level=logging.DEBUG, format="%(asctime)s %(message)s")
logging.info("====================")


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
