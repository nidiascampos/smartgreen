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
        # get the latest module data
        data = collection.find_one({ "module": module }, sort=[ ("when",-1) ])
        # verify if the data has been published already
        # (that means that the module isn't sending data regularly correctly)
        if data["published"] == False:
            payload.append(data)
        else:
            logging.warning("!!! Data from module " + data["module"] + " already published, ignoring (id: " + str(data["_id"]) + ")")
    # logs data payload
    logging.info("Modules data: ")
    logging.info(payload)

    return payload


def mongo_update(module_id):
    # set data status as published
    collection.find_one_and_update({ "_id": module_id }, { "$set": { "published": True } })


def publish_thingspeak():
    logging.info("Publishing...")

    # get data from mongodb
    modules_data = mongo_read()
    msgs = []

    # split data and publish to thingspeak
    for module in modules_data:
        # string format required by thingspeak API
        msg = "field1=%f&field2=%d&field3=%d&field4=%d&field5=%d&field6=%d&field7=%d" % (module["battery"],module["15cm"],module["15cm_bias"],module["45cm"],module["45cm_bias"],module["75cm"],module["75cm_bias"])
        # every module have its own channel, and its own API key
        if module["module"] == "01":
            logging.info("module 1 data ok")
            thingspeak_channel = "41313"
            thingspeak_key = "6622XUT2PQOITIX4"
        elif module["module"] == "02":
            logging.info("module 2 data ok")
            thingspeak_channel = "255953"
            thingspeak_key = "IOF8CFV6JDP3DY8Q"
        elif module["module"] == "03":
            logging.info("module 3 data ok")
            thingspeak_channel = "256208"
            thingspeak_key = "RCV2LDXRFWWU0NWV"
        elif module["module"] == "04":
            logging.info("module 4 data ok")
            thingspeak_channel = "256209"
            thingspeak_key = "ITNOWFUYCS7ZVIQ3"
        # publish each module data
        publish.single("channels/" + thingspeak_channel + "/publish/" + thingspeak_key,
                        msg, hostname="mqtt.thingspeak.com", port=1883)
        # update data status to published
        mongo_update(module["_id"])

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
    
