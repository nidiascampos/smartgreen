import paho.mqtt.client as mqtt

def mqtt_connect(client, userdata, rc):
    print("Conectado com resultado "+str(rc))
    client.subscribe("/sensor/#")

def mqtt_message(client, userdata, msg):
    # print(msg.topic+" "+str(msg.payload))
    print("Received message '" + str(msg.payload) + "' on topic '"
          + msg.topic + "' with QoS " + str(msg.qos))
    print("User data " + str(userdata))
    mongo_add_message(msg)

def mongo_add_message(msg):
    from datetime import datetime
    date = datetime.utcnow()
    db.teste03.update_one({
        "_id": msg.topic
    },{
        "$set": {
            "value": msg.payload,
            "when": date
        }
    }, upsert= True)

from pymongo import MongoClient
clientMongo = MongoClient('localhost:27017')
db = clientMongo.SmartGreen

client = mqtt.Client()
client.on_connect = mqtt_connect
client.on_message = mqtt_message

client.connect("localhost", 1883, 60)

client.loop_forever()