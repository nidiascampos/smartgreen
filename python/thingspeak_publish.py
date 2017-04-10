import logging
import time
import paho.mqtt.publish as publish
from pymongo import MongoClient
# from pppd import PPPConnection


def mongo_read():

    # modules = ["01", "02", "03", "04"]
    modules = ["01", "02"]
    payload = []

    for module in modules:
        # obter a ultima leitura do sensor
        data = collection.find_one({ "module": module }, sort=[ ("when",-1) ])
        if data["published"] == False:
            payload.append(data)
    logging.info("Modules data: ")
    logging.info(payload)

    return payload


def mongo_update(module_id):
    collection.find_one_and_update({ "_id": module_id }, { "$set": { "published": True } })


def publish_thingspeak():
    logging.info("Publishing to ThingSpeak")

    modules_data = mongo_read()
    print(modules_data)  # FIXME: DEBUG

    msgs = []

    for module in modules_data:
        msg = "field1=%f&field2=%d&field3=%d&field4=%d&field5=%d&field6=%d&field7=%d" % (module["battery"],module["15cm"],module["15cm_bias"],module["45cm"],module["45cm_bias"],module["75cm"],module["75cm_bias"])
        if module["module"] == "01":
            print("module 01")
            thingspeak_channel = "41313"
            thingspeak_key = "6622XUT2PQOITIX4"
        elif module["module"] == "02":
            print("module 02")
            thingspeak_channel = "255953"
            thingspeak_key = "IOF8CFV6JDP3DY8Q"
        publish.single("channels/" + thingspeak_channel + "/publish/" + thingspeak_key,
                        msg, hostname="mqtt.thingspeak.com", port=1883)
        mongo_update(module["_id"])
        # msgs.append(msg)

    # print("Messages :", msgs)  # FIXME: DEBUG

    logging.info("Published OK")

    return True

# Basic config
logging.basicConfig(filename="/var/log/smartgreen/thingspeak_publish.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
logging.info("THINGSPEAK PUBLISH ====================")  # String to separate logs


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.teste07


# Publish data
publish_thingspeak()

# logging.info("Connecting")
# ppp = PPPConnection(sudo=False, call='claro')  # activate PPP connection
# if ppp.connected():
#     logging.info("Connected")
#     publish_adafruit()
#     time.sleep(5)
#     ppp.disconnect()
#     logging.info("Disconnected")
    
