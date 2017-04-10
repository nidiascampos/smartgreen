import logging
import time
import paho.mqtt.publish as publish
from pymongo import MongoClient
from pppd import PPPConnection


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.coleta02


# Basic config
logging.basicConfig(filename="/var/log/smartgreen/adafruit.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
#logging.info("====================")  # String to separate logs


def mongo_read():
    sensors = ["rain", "temperature", "temperature_internal", "battery_current", "battery_voltage"]
#    sensors = ["03", "04"]
#    depths = ["15", "45", "75", "vcc"]
    payload = []
    for sensor in sensors:
        item = collection.find({sensor: {"$exists": 1}}).sort("when", -1)
        value = item[0][sensor]
        data = [sensor, value]
        payload.append(data)
    logging.info("Sensors data:")
    logging.info(payload)
    return payload


def publish_adafruit():

    adafruit_username = "andreibosco"
    adafruit_key = "f38fefdd1fa94e2aaec9fd857b036e19"

    sensors_data = mongo_read()
    # print(sensors_data)  # FIXME: DEBUG

    msgs = []

    for sensor in sensors_data:
        # sensor[0] = sensor name
        # sensor[1] = sensor data
        # QoS = 0
        # Retain = True
        # ex.: andreibosco/f/sink_temperature, 29.37, 0, True
        msg = (adafruit_username + "/f/sink_" + str(sensor[0]), str(sensor[1]), 0, True)
        msgs.append(msg)

    # print("Messages :", msgs)  # FIXME: DEBUG

    publish.multiple(msgs,
                     hostname="io.adafruit.com",
                     port=1883,
                     auth={"username": adafruit_username, "password": adafruit_key})

    logging.info("Published to adafruit")  # FIXME: DEBUG

    return True


# Publish data
logging.info("Connecting")
ppp = PPPConnection(sudo=False, call='claro')  # activate PPP connection
if ppp.connected():
    logging.info("Connected")
    publish_adafruit()
    time.sleep(5)
    ppp.disconnect()
    logging.info("Disconnected")

# debug
#publish_adafruit()
