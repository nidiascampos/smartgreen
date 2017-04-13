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


# Pin configuration.
GPIO.setmode(GPIO.BCM)
pin = 26


# Rain Sensor
GPIO.setup(pin, GPIO.IN)
GPIO.add_event_detect(pin, GPIO.FALLING)
# sensor_read = GPIO.input(pin)

# if sensor_read == 0:
#     rain = True
# else:
#     rain = False

while 1:
    if GPIO.event_detected(pin):
        print("Chuva")
        logging.info("Chuva")
        rain = True


# Save data
# logging.info(sensor_read)
db.teste07.insert({
    "when": datetime.datetime.utcnow(),
    "rain": rain
})


# Cleanup GPIO
GPIO.cleanup(pin)

# Exemplo
# add rising edge detection on a channel
# GPIO.add_event_detect(channel, GPIO.RISING)
# do_something()
# if GPIO.event_detected(channel):
#     print('Button pressed')
