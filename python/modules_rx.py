#!/usr/bin/env python

# Based on RF24Network helloworld_rx.py

from __future__ import print_function
import time
import datetime
import logging
from pymongo import MongoClient
from struct import *
from RF24 import *
from RF24Network import *

# CE Pin, CSN Pin, SPI Speed
radio = RF24(RPI_V2_GPIO_P1_15, RPI_V2_GPIO_P1_24, BCM2835_SPI_SPEED_8MHZ)
network = RF24Network(radio)

# Address of our node in Octal format (01, 021, etc)
octlit = lambda n:int(n, 8)
this_node = octlit("00")

# Start radio
radio.begin()
time.sleep(0.1)

# Format: channel, node address
network.begin(90, this_node)    # channel 90

# Print radio config
radio.printDetails()
packets_sent = 0
last_sent = 0

# Logging config
logging.basicConfig(filename="/var/log/smartgreen/modules_rx.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
logging.info("MODULES_RX STARTED ====================")

# MongoDB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.coleta03


def mongo_add_message(module_id, module_vcc,
                      sensor_15cm, sensor_15cm_bias,
                      sensor_45cm, sensor_45cm_bias,
                      sensor_75cm, sensor_75cm_bias):
    # inserting data into mongodb
    collection.insert({
        "type": "module",
        "module": module_id,
        "channel": int(module_id),
        "when": datetime.datetime.utcnow(),
        "15cm": sensor_15cm,
        "15cm_bias": sensor_15cm_bias,
        "45cm": sensor_45cm,
        "45cm_bias": sensor_45cm_bias,
        "75cm": sensor_75cm,
        "75cm_bias": sensor_75cm_bias,
        "battery": module_vcc,
        "published": False
    })


def mongo_add_message_alt(module_id, module_vcc,
                          sensor_rain_analog, sensor_rain_digital,
                          sensor_temperature):
    # inserting data into mongodb
    collection.insert({
        "type": "module",
        "module": module_id,
        "channel": 0,
        "when": datetime.datetime.utcnow(),
        "temperature": sensor_temperature,
        "raining": sensor_rain_digital,
        "rain": sensor_rain_analog,
        "battery": module_vcc,
        "published": False
    })


# Loop
while 1:
    network.update()
    while network.available():
        # read data from network (expecting 28 bytes)
        header, payload = network.read(28)

        # verify payload length
        # print("Payload length:", len(payload))
        if len(payload) == 28:
            # unpack payload struct
            wm15, wm15bias, wm45, wm45bias, wm75, wm75bias, vcc = unpack('<llllllf', bytes(payload))

            # print payload content
            # print('Payload: ', oct(header.from_node),
            #      wm15, wm15bias,
            #      wm45, wm45bias,
            #      wm75, wm75bias, vcc)

            # output payload content to log file
            payload_log = "Payload from module ID " + str(oct(header.from_node)) + ': ' + str(wm15) + ' ' + str(wm15bias) + ' ' + str(wm45) + ' ' + str(wm45bias) + ' ' + str(wm75) + ' ' + str(wm75bias) + ' ' + str(vcc)
            print(payload_log)
            logging.info(payload_log)

            # add payload to mongoDB
            mongo_add_message(oct(header.from_node), vcc,
                              wm15, wm15bias,
                              wm45, wm45bias,
                              wm75, wm75bias)
            time.sleep(1)
        elif len(payload) == 13:
            # unpack payload struct
            vcc, temperature, rain_analog, rain_digital = unpack('<ffl?', bytes(payload))

            # output payload content to log file
            payload_log = "Payload from module ID " + str(oct(header.from_node)) + ': ' + str(rain_analog) + ' ' + str(rain_digital) + ' ' + str(temperature) + ' ' +  str(vcc)
            print(payload_log)
            logging.info(payload_log)

            # add payload to mongoDB
            mongo_add_message_alt(oct(header.from_node), vcc,
                                  rain_analog, rain_digital,
                                  temperature)
            time.sleep(1)
        else:
            # log payload wrong size and module id
            payload_log = "!!! Wrong payload size from module ID " + str(oct(header.from_node)) + ": " + str(len(payload)) + " bytes"
            # payload_log = "!!! Wrong payload size from : " + str(len(payload)) + ". Expected 28 bytes. Module ID: " + str(oct(header.from_node))
            # print('!!! Wrong payload size: expected 28 bytes. Module ID: ', oct(header.from_node))
            print(payload_log)
            logging.warn(payload_log)
            time.sleep(1)
