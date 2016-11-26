import paho.mqtt.client as mqtt
from pymongo import MongoClient


def mqtt_connect(client, userdata, rc):
    print("Connected with result: "+str(rc))
    client.subscribe("/sensor/#")


def mqtt_message(client, userdata, msg):
    # print(msg.topic+" "+str(msg.payload))
    print("Received message '" + str(msg.payload) + "' on topic '"
          + msg.topic + "' with QoS " + str(msg.qos))
    print("User data " + str(userdata))
    mongo_add_message(msg)


def mongo_add_message(msg):
    import datetime
    db.teste03.update_one({
        "_id": msg.topic
    }, {
        "$push": {
            "events": {
                "value": msg.payload,
                "when": datetime.datetime.utcnow()
            }
        }
    }, upsert=True)


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen

# MQTT
client_mqtt = mqtt.Client()
client_mqtt.on_connect = mqtt_connect
client_mqtt.on_message = mqtt_message
client_mqtt.connect("localhost", 1883, 60)
client_mqtt.loop_forever()
