import logging
import datetime
import RPi.GPIO as GPIO
from pymongo import MongoClient

# Logging config
logging.basicConfig(filename="/var/log/smartgreen/sensor_rain.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


# Pin configuration
GPIO.setmode(GPIO.BCM)
pin = 26


# Save data to MongoDB
def mongo_add_message(rain):
    # inserting data into mongodb
    db.teste07.insert({
        "sensor": "rain",
        "when": datetime.datetime.utcnow(),
        "rain": rain,
        "published": False
    })


# Read Rain Sensor
GPIO.setup(pin, GPIO.IN)
sensor_read = GPIO.input(pin)


# Check if it's raining or not and save to MongoDB
if sensor_read == 0:
    rain = True
    print "Chuva"
    logging.info("Chuva")
else:
    rain = False
    print "Sem chuva"
    logging.info("Sem chuva")
mongo_add_message(rain)


# Cleanup GPIO
GPIO.cleanup(pin)
