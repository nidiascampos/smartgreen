#!/usr/bin/env python

import logging
import paho.mqtt.publish as publish
import time
import subprocess
import sys
from pymongo import MongoClient
from pppd import PPPConnection


# enable USB port
def usb_enable():
  try:
    bashCommand = "/home/pi/smartgreen/shell_scripts/usb_enable.sh"
    process = subprocess.check_output(['sudo', bashCommand])
    logging.info("USB enabled")
    print "USB enabled"
  except subprocess.CalledProcessError:
    logging.info("!!! Error: USB already enabled?")
    print "!!! Error: USB already enabled?"

def usb_disable():
  try:
    bashCommand = "/home/pi/smartgreen/shell_scripts/usb_disable.sh"
    process = subprocess.check_output(['sudo', bashCommand])
    logging.info("USB disabled")
    print "USB disabled"
  except subprocess.CalledProcessError:
    logging.info("!!! Error: USB already disabled?")
    print "!!! Error: USB already disabled?"

def mongo_read():
    logging.info("Reading data from MongoDB")
    print "MongoDB"

    # modules = ["01", "02", "03", "04"]
    # modules = ["01", "02"]
    modules = ["01"]
    sensors = ["rain", "temperature"]
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

    for sensor in sensors:
        data = collection.find_one({"sensor": sensor}, sort=[("when", -1)])
        if data["published"] is False:
            payload.append(data)
            logging.info("Adding data to payload")
            print "Adding data to payload"
        else:
            logging.warning("!!! Data from " + data["sensor"] + "sensor already published, ignoring (id: " + str(data["_id"]) + ")")
            print "Data already published"

    # logs data payload
    logging.info("Modules data: ")
    logging.info(payload)

    return payload


def mongo_update(module_id):
    logging.info("Setting payload data as published")
    print "Setting payload data as published"
    # set data status as published
    collection.find_one_and_update({"_id": module_id}, {"$set": {"published": True}})


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
                if item["type"] == "sensor":
                    # raspberry sensors data (channel 0)
                    if item["sensor"] == "temperature":
                        data.append("field1=%f" % (item["temperature"]))
                    elif item["sensor"] == "rain":
                        data.append("field2=%i" % (item["rain"]))
                # modules sensors data (other channels)
                else:
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
collection = db.teste08


# Enable USB port
usb_enable()
time.sleep(5)

# Connect using PPP (3 attempts with 5 minutes interval)
for i in range(1, 4):
    connected = False
    logging.info("Connecting...")
    print "Connecting"
    while True:
        try:
            logging.info("Attempt n. " + str(i))
            print "Attempt n. " + str(i)
            ppp = PPPConnection(sudo=False, call='claro')
        except:
            logging.error("Failed to connect")
            print "Failed to connect"
            usb_disable()
            if i is 3:
                logging.error("!!! Unable to connect after 3 attempts, exiting")
                sys.exit("Unable to connect, exiting")
            else:
                time.sleep(30)
                # time.sleep(300)  # 5 min
                usb_enable()
                break
        else:
            logging.info("Success")
            print "Success"
            connected = True
            break
    if connected is True:
        break

# ppp = PPPConnection(sudo=False, call='claro')
if ppp.connected():
    logging.info("PPP: connected")
    print "Connected"
    time.sleep(10)
    publish_thingspeak()
    # wait 5s before closing ppp connection
    time.sleep(5)
    print "Disconnecting"
    ppp.disconnect()
    logging.info("PPP: Disconnected")

# publish_thingspeak()

# Disable USB port
usb_disable()
