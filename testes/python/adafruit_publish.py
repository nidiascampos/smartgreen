import paho.mqtt.publish as publish
from pymongo import MongoClient
# from paho.mqtt.publish import multiple
# from pppd import PPPConnection


def mongo_read():
    # sensors = ["01", "02", "03", "04"]
    sensors = ["01", "02"]
    depths = ["15", "45", "60"]
    payload = []
    for sensor in sensors:
        for depth in depths:
            item = collection.find({"sensor": sensor, "depth": depth}).sort("when", -1)
            sensor = item[0]["sensor"]
            depth = item[0]["depth"]
            average = item[0]["average"]
            # DEBUG
            # print('sensor: ', sensor)
            # print('depth: ', depth)
            # print('average: ', average)
            data = [sensor, depth, average]
            payload.append(data)
    return payload


# def publish_adafruit(adafruit_topic, adafruit_payload):
def publish_adafruit():

    adafruit_username = "andreibosco"
    adafruit_key = "f38fefdd1fa94e2aaec9fd857b036e19"

    sensors_data = mongo_read()
    print(sensors_data)

    msgs = []

    for sensor in sensors_data:
        print("teste: ", sensor[0])
        msg = (adafruit_username + "/f/WM_" + sensor[0] + "_" + sensor[1], sensor[2], 0, True)
        msgs.append(msg)

    print(msgs)

    # msgs = [(adafruit_username + "/f/WM_01_15", "13", 0, True),
    #         (adafruit_username + "/f/WM_01_45", "23", 0, True),
    #         (adafruit_username + "/f/WM_01_75", "33", 0, True),
    #         (adafruit_username + "/f/WM_01_VCC", "4.7", 0, True)]
    # print(msgs)

    publish.multiple(msgs,
                     hostname="io.adafruit.com",
                     port=1883,
                     auth={"username": adafruit_username, "password": adafruit_key})

    # publish.multiple(msgs,
    #                  hostname="io.adafruit.com",
    #                  port=1883,
    #                  auth={'username': adafruit_username, 'password': adafruit_key}
    #                  )]

    # publish.single(adafruit_username+"/f/"+adafruit_topic, adafruit_payload, qos=0, retain=True,
    #                hostname="io.adafruit.com",
    #                port=1883,
    #                auth={'username': adafruit_username, 'password': adafruit_key}
    #                )
    #
    print("Published to adafruit")  # FIXME: Debug


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen
collection = db.teste05

# Publish data
publish_adafruit()
# ppp = PPPConnection(sudo=False, call='tim')  # activate PPP connection
# if ppp.connected():
#     print('connected')
