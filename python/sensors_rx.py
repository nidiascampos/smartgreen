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
logging.basicConfig(filename="/var/log/smartgreen/sensors_rx.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
logging.info("SENSORS_RX STARTED ====================")

# MongoDB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


def mongo_add_message(module_id, module_vcc,
                      sensor_15cm, sensor_15cm_bias,
                      sensor_45cm, sensor_45cm_bias,
                      sensor_75cm, sensor_75cm_bias):
    # inserting data into mongodb
    db.teste07.insert({
        "module": module_id,
        "15cm": sensor_15cm,
        "15cm_bias": sensor_15cm_bias,
        "45cm": sensor_45cm,
        "45cm_bias": sensor_45cm_bias,
        "75cm": sensor_75cm,
        "75cm_bias": sensor_75cm_bias,
        "when": datetime.datetime.utcnow(),
        "battery": module_vcc,
        "published": False
    })


# Loop
while 1:
    network.update()
    while network.available():
        header, payload = network.read(28)
        # verify payload length
        print("Payload length:", len(payload))
        # unpack payload struct
        wm15, wm15bias,
        wm45, wm45bias,
        wm75, wm75bias,
        vcc = unpack('<llllllf', bytes(payload))
        # print payload content
        print('Payload: ', oct(header.from_node),
              wm15, wm15bias,
              wm45, wm45bias,
              wm75, wm75bias, vcc)
        # output payload content to log file
    payload_log = "Payload: " + str(oct(header.from_node)) + ' '
    + str(wm15) + ' ' + str(wm15bias) + ' '
    + str(wm45) + ' ' + str(wm45bias) + ' '
    + str(wm75) + ' ' + str(wm75bias) + ' '
    + str(vcc)
    logging.info(payload_log)
    # add payload to mongoDB
    mongo_add_message(oct(header.from_node), vcc,
                      wm15, wm15bias,
                      wm45, wm45bias,
                      wm75, wm75bias)
    time.sleep(1)
