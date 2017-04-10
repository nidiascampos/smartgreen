import logging
import w1thermsensor
import datetime
from pymongo import MongoClient
from w1thermsensor import W1ThermSensor


# Logging config
logging.basicConfig(filename="/var/log/smartgreen/temperature_sensor.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
#logging.info("====================")


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


# Temperature Sensor
sensor = W1ThermSensor()
temp_celsius = sensor.get_temperature()


# Save data
logging.info(temp_celsius)
db.coleta02.insert({
    "when": datetime.datetime.utcnow(),
    "temperature": temp_celsius
})
