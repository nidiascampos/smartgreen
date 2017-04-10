#!/usr/bin/env python

#
# Simplest possible example of using RF24Network,
#
#  RECEIVER NODE
#  Listens for messages from the transmitter and prints them out.
#
from __future__ import print_function
import time
import datetime
import logging
from pymongo import MongoClient
from os.path import expanduser
from struct import *
from RF24 import *
from RF24Network import *

# CE Pin, CSN Pin, SPI Speed

radio = RF24(RPI_V2_GPIO_P1_15, RPI_V2_GPIO_P1_24, BCM2835_SPI_SPEED_8MHZ)
network = RF24Network(radio)

# millis = lambda: int(round(time.time() * 1000))
octlit = lambda n:int(n, 8)

# Address of our node in Octal format (01, 021, etc)
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

# MongoDB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen

def mongo_add_message(module_id, module_vcc, sensor_15cm, sensor_15cm_bias, sensor_45cm, sensor_45cm_bias, sensor_75cm, sensor_75cm_bias):
    # inserting data into mongodb
    db.teste07.insert({
        "sensor": module_id,
        "15cm": sensor_15cm,
        "15cm_bias": sensor_15cm_bias,
        "45cm": sensor_45cm,
        "45cm_bias": sensor_45cm_bias,
        "75cm": sensor_75cm,
        "75cm_bias": sensor_75cm_bias,
        "when": datetime.datetime.utcnow(),
        "battery": module_vcc,
        "published": "no"
    })

while 1:
    network.update()
    while network.available():
        header, payload = network.read(28)
        print("payload length ", len(payload))
        # ms, number = unpack('<LL', bytes(payload))
        wm15, wm15bias, wm45, wm45bias, wm75, wm75bias, vcc = unpack('<llllllf', bytes(payload))
        # print('Received payload ', number, ' at ', ms, ' from ', oct(header.from_node))
        print('Payload: ', oct(header.from_node), wm15, wm15bias, wm45, wm45bias, wm75, wm75bias, vcc)
        mongo_add_message(oct(header.from_node), vcc, wm15, wm15bias, wm45, wm45bias, wm75, wm75bias)
    time.sleep(1)

