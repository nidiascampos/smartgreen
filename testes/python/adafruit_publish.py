import paho.mqtt.publish as publish
from pymongo import MongoClient
from pppd import PPPConnection


def mongo_read():
    # sensors = ["01", "02", "03", "04"]
    sensors = ["01", "02"]
    depths = ["15", "45", "60", "vcc"]
    payload = []
    for sensor in sensors:
        for depth in depths:
            if depth == "vcc":
                item = collection.find({"sensor": sensor, "vcc": {"$exists": 1}}).sort("when", -1)
                sensor = item[0]["sensor"]
                depth = "vcc"
                value = item[0]["vcc"]
            else:
                item = collection.find({"sensor": sensor, "depth": depth}).sort("when", -1)
                sensor = item[0]["sensor"]
                depth = item[0]["depth"]
                value = item[0]["average"]
            # DEBUG
            print('sensor: ', sensor)
            print('depth: ', depth)
            print('value: ', value)
            data = [sensor, depth, value]
            payload.append(data)
    return payload


# def publish_adafruit(adafruit_topic, adafruit_payload):
def publish_adafruit():

    adafruit_username = "andreibosco"
    adafruit_key = "f38fefdd1fa94e2aaec9fd857b036e19"

    sensors_data = mongo_read()
    # print(sensors_data)  # FIXME: DEBUG

    msgs = []

    for sensor in sensors_data:
        msg = (adafruit_username + "/f/WM_" + sensor[0] + "_" + sensor[1], sensor[2], 0, True)
        msgs.append(msg)

    # print("Messages :", msgs)  # FIXME: DEBUG

    publish.multiple(msgs,
                     hostname="io.adafruit.com",
                     port=1883,
                     auth={"username": adafruit_username, "password": adafruit_key})

    print("Published to adafruit")  # FIXME: Debug


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.teste05


# Publish data
ppp = PPPConnection(sudo=False, call='tim')  # activate PPP connection
if ppp.connected():
    print("Connected")
    publish_adafruit()
    ppp.disconnect()
    print("Disconnected")

# publish_adafruit()
