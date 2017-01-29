import logging
import datetime
import CHIP_IO.GPIO as GPIO
from pymongo import MongoClient

# Logging config
logging.basicConfig(filename="/var/log/smartgreen/rain_sensor.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
#logging.info("====================")


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


# Pin configuration.
pin = "XIO-P0"


# Rain Sensor
GPIO.setup(pin, GPIO.IN)
sensor_read = GPIO.input(pin)


# Save data
logging.info(sensor_read)
db.coleta02.insert({
    "when": datetime.datetime.utcnow(),
    "rain": sensor_read
})


# Cleanup GPIO
GPIO.cleanup(pin)
