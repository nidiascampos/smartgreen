import logging
import time
import paho.mqtt.publish as publish
from pymongo import MongoClient
from pppd import PPPConnection


def mongo_read():
    # sensors = ["01", "02", "03", "04"]
    sensors = ["03", "04"]
    depths = ["15", "45", "75", "vcc"]
    payload = []
    for sensor in sensors:
        for depth in depths:
            if depth == "vcc":
                item = collection.find({"sensor": sensor, "vcc": {"$exists": 1}}).sort("when", -1)
                sensor = item[0]["sensor"]
                depth = "vcc"
                value = item[0]["vcc"]
            else:
                item = collection.find({"sensor": sensor, "depth": depth}).sort("when", -1)
                sensor = item[0]["sensor"]
                depth = item[0]["depth"]
                value = item[0]["average"]
            data = [sensor, depth, value]
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
        msg = (adafruit_username + "/f/WM_" + sensor[0] + "_" + sensor[1], sensor[2], 0, True)
        msgs.append(msg)

    # print("Messages :", msgs)  # FIXME: DEBUG

    publish.multiple(msgs,
                     hostname="io.adafruit.com",
                     port=1883,
                     auth={"username": adafruit_username, "password": adafruit_key})

    logging.info("Published to adafruit")  # FIXME: DEBUG

    return True

# Basic config
logging.basicConfig(filename="/home/pi/logs/adafruit.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
logging.info("====================")  # String to separate logs


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.teste06


# Publish data
logging.info("Connecting")
ppp = PPPConnection(sudo=False, call='claro')  # activate PPP connection
if ppp.connected():
    logging.info("Connected")
    publish_adafruit()
    time.sleep(5)
    ppp.disconnect()
    logging.info("Disconnected")
