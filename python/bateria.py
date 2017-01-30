import logging
import datetime
import subprocess
from pymongo import MongoClient

# Logging config
logging.basicConfig(filename="/var/log/smartgreen/chip_sensor.log",
                    level=logging.DEBUG,
                    format="%(asctime)s %(message)s")
#logging.info("====================")


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen


# Check temperature and battery status (bash script)
# this script must be on root's $PATH
# the script output should be:
# temperature,battery voltage,battery current
# (celsius, miliVolts, miliAmp)
chip_status = subprocess.check_output(['battery-vbus.sh'])
chip_status = chip_status.strip().split(',')


# Save data
logging.info(chip_status)
db.coleta02.insert({
    "when": datetime.datetime.utcnow(),
    "temperature_internal": chip_status[0],
    "battery_voltage": chip_status[1],
    "battery_current": chip_status[2]
})

