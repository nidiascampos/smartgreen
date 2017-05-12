#!/usr/bin/env python

import logging
import paho.mqtt.publish as publish
import time
import socket
import pppd
import sys
from subprocess import call
from pymongo import MongoClient


def is_connected():  # verify internet connection
    REMOTE_SERVER = "www.google.com"
    logging.info("Verifying connection")
    print "Verifying connection"
    try:
        # see if we can resolve the host name
        host = socket.gethostbyname(REMOTE_SERVER)
        # connect to the host
        socket.create_connection((host, 80), 2)
        logging.info("Connection OK")
        print "Connection OK"
        return True
    except:
        pass
    logging.info("Not connected")
    print "Not connected"
    return False


def connect_3g():
    try:
        logging.info("Connecting...")
        print "Connecting..."
        pppd.PPPConnection(sudo=False, call='claro')
        logging.info("Connected")
        print "Connected"
        return True
    except pppd.PPPConnectionError:
        logging.error("Failed to connect")
        print "Failed to connect"
        return False


def disconnect_3g():
    call(["poff"])


def mongo_read():
    logging.info("Reading data from MongoDB")
    print "MongoDB"

    # modules = ["01", "02", "03", "04", "05"]
    modules = ["02", "05"]
    # sensors = ["rain", "temperature"]
    payload = []

    for module in modules:
        # get the latest module data
        data = collection.find_one({"module": module}, sort=[("when", -1)])
        # verify if the data has been published already
        # (that means that the module isn't sending data regularly correctly)
        if data["published"] is False:
            payload.append(data)
            logging.info("Adding data to payload")
            print "Adding data to payload"
        else:
            logging.warning("!!! Data from module " + data["module"] + " already published, ignoring (id: " + str(data["_id"]) + ")")
            print "Data already published"

    # for sensor in sensors:
    #     data = collection.find_one({"sensor": sensor}, sort=[("when", -1)])
    #     if data["published"] is False:
    #         payload.append(data)
    #         logging.info("Adding data to payload")
    #         print "Adding data to payload"
    #     else:
    #         logging.warning("!!! Data from " + data["sensor"] + "sensor already published, ignoring (id: " + str(data["_id"]) + ")")
    #         print "Data already published"

    # logs data payload
    logging.info("Modules data: ")
    logging.info(payload)

    return payload


def mongo_update(module_id):
    logging.info("Setting payload data as published")
    print "Setting payload data as published"
    # set data status as published
    collection.update_one({"_id": module_id}, {"$set": {"published": True}})
    time.sleep(1)


def publish_thingspeak():
    logging.info("Publishing...")

    # get data from mongodb
    payload = mongo_read()
    print payload

    # setting thingspeak channels and keys
    thingspeak = [["258089", "PELSB44E4BVOIHHQ"],
                  ["41313", "6622XUT2PQOITIX4"],
                  ["255953", "IOF8CFV6JDP3DY8Q"]]

    # organize data by channel and publish to thingspeak
    for channel in range(0, 3):
        print channel
        data = []
        msg = ""
        for item in payload:
            if int(item["channel"]) == channel:
                print item
                print "channel: " + str(channel)
                if item["module"] == "05":
                    # special module: temperature and rain
                    data.append("field1=%f&field2=%f&field3=%d&field4=%i" % (item["battery"], item["temperature"], item["rain"], item["raining"]))
                else:
                    # regular modules
                    data.append("field1=%f&field2=%d&field3=%d&field4=%d&field5=%d&field6=%d&field7=%d" % (item["battery"], item["15cm"], item["15cm_bias"], item["45cm"], item["45cm_bias"], item["75cm"], item["75cm_bias"]))
        msg = "&".join(data)
        print "msg: " + msg
        print "thing chan: " + thingspeak[channel][0]
        print "thing key: " + thingspeak[channel][1]
        topic = "channels/" + thingspeak[channel][0] + \
                "/publish/" + thingspeak[channel][1]
        print "topic: " + topic
        # publish each module data
        if msg:
            logging.info("Publishing now")
            print "publishing now"
            publish.single(topic, msg, hostname="mqtt.thingspeak.com", port=1883)
            # update data status to published
            mongo_update(item["_id"])
        else:
            logging.info("Empty msg data")
            print "empty msg data"

    logging.info("Published OK")

    return True


# Basic config
logging.basicConfig(filename="/var/log/smartgreen/publish_thingspeak.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
# String to separate logs
logging.info("THINGSPEAK PUBLISH ====================")


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.coleta03


if is_connected() is False:
    disconnect_3g()  # stopping pppd just in case
    for i in range(1, 4):
        print "Attempt n. " + str(i)
        if connect_3g() is True:
            break
        elif i is 3:
            logging.error("!!! Unable to connect after 3 attempts, exiting")
            print "!!! Unable to connect after 3 attempts, exiting"
            sys.exit("Unable to connect, exiting")
        else:
            print "Retrying in 10 seg"
            time.sleep(30)
            continue
else:
    logging.info("Connection OK")
    print "Connection OK" 

publish_thingspeak()

disconnect_3g()  # stopping pppd just in case
