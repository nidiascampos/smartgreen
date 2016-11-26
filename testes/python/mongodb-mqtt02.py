import paho.mqtt.client as mqtt
from pymongo import MongoClient


def mqtt_connect(client, userdata, rc):
    print("Connected with result: "+str(rc))
    client.subscribe("/#")


def mqtt_message(client, userdata, msg):
    # print(msg.topic+" "+str(msg.payload))
    print("Received message '" + str(msg.payload) + "' on topic '"
          + msg.topic + "' with QoS " + str(msg.qos))
    print("User data " + str(userdata))
    mongo_add_message(msg)


def mongo_add_message(msg):
    import datetime
    data_list = msg.payload.split(',')
    data_std = data_list.pop(21)
    data_average = data_list.pop(20)
    topic_list = msg.topic.split('/')
    sensor_id = topic_list[1]
    sensor_depth = topic_list[2]
    db.teste04.insert({
        "sensor": sensor_id,
        "depth": sensor_depth,
        "average": data_average,
        "raw": tuple(data_list),
        "STD": data_std,
        "when": datetime.datetime.utcnow()
    })


# DB
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen

# MQTT
client_mqtt = mqtt.Client()
client_mqtt.on_connect = mqtt_connect
client_mqtt.on_message = mqtt_message
client_mqtt.connect("localhost", 1883, 60)
client_mqtt.loop_forever()
