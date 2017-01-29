import logging
import datetime
import CHIP_IO.GPIO as GPIO
#from pymongo import MongoClient
from os.path import expanduser

home = expanduser("~")

# Logging config
logging.basicConfig(filename=home+"/logs/rain_sensor.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
logging.info("====================")

# DB
#clientMongo = MongoClient('localhost:27017')
#db = clientMongo.SmartGreen

# Pin configuration.
pin = "XIO-P0"

# Rain Sensor
GPIO.setup(pin, GPIO.IN)
#sensor_state = GPIO.input("XIO-P0")
#GPIO.wait_for_edge("XIO-P0", GPIO.BOTH)
#GPIO.add_event_detect("XIO-P0", GPIO.BOTH)
#GPIO.add_event_callback("XIO-P0", GPIO.FALLING, rain_over)
#GPIO.add_event_callback("XIO-P0", GPIO.RISING, rain_started)

# Pool in a loop
print("aguardando deteccao")

try:
  while True:
    GPIO.wait_for_edge("XIO-P0", GPIO.BOTH)
    sensor_read = GPIO.input("XIO-P0")
    print("evento detectado")
    print(sensor_read)
except KeyboardInterrupt:
  GPIO.cleanup("XIO-P0")

GPIO.cleanup("XIO-P0")

#if GPIO.event_detected("XIO-P0"):
#  print("evento detectado")
#  sensor_read = GPIO.input("XIO-P0")
#  print(sensor_read)

