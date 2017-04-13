import logging
import datetime
import RPi.GPIO as GPIO
from pymongo import MongoClient

# Logging config
logging.basicConfig(filename="/var/log/smartgreen/sensor_rain.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
#logging.info("====================")


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


# Pin configuration.
GPIO.setmode(GPIO.BCM)
pin = 23


# Rain Sensor
GPIO.setup(pin, GPIO.IN)
sensor_read = GPIO.input(pin)


# Save data
logging.info(sensor_read)
db.teste07.insert({
    "when": datetime.datetime.utcnow(),
    "rain": sensor_read
})


# Cleanup GPIO
GPIO.cleanup(pin)
