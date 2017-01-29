import logging
#import datetime
import time
import CHIP_IO.GPIO as GPIO
#from pymongo import MongoClient
from os.path import expanduser

home = expanduser("~")

# Logging config
#logging.basicConfig(filename=home+"/logs/rain_sensor.log",
#                    level=logging.DEBUG,
#                    format="%(asctime)s %(message)s")
#logging.info("====================")

# DB
#clientMongo = MongoClient('localhost:27017')
#db = clientMongo.SmartGreen

# Pin configuration.
pin = "XIO-P0"

# Rain Sensor
GPIO.setup(pin, GPIO.IN)

# Pool in a loop
print("aguardando deteccao")

try:
  while True:
    # read the pin every 5 seconds
    #GPIO.wait_for_edge("XIO-P0", GPIO.BOTH)
    sensor_read = GPIO.input("XIO-P0")
#    print("evento detectado")
    print(time.asctime())
    print(sensor_read)
    time.sleep(60)
except KeyboardInterrupt:
  GPIO.cleanup("XIO-P0")

GPIO.cleanup("XIO-P0")

#if GPIO.event_detected("XIO-P0"):
#  print("evento detectado")
#  sensor_read = GPIO.input("XIO-P0")
#  print(sensor_read)

