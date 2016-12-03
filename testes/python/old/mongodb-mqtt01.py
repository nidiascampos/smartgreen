import paho.mqtt.client as mqtt


def get_db():
    from pymongo import MongoClient
    client_mongo = MongoClient('localhost:27017')
    db = client_mongo.SmartGreen
    return db


def mqtt_connect(client, userdata, rc):
    print("Connected with result: "+str(rc))
    client.subscribe("/sensor/#")

# def add_message(db):
#     db.teste03.insert({"name": "Canada"})


def mqtt_message(client, userdata, msg):
    # print(msg.topic+" "+str(msg.payload))
    print("Received message '" + str(msg.payload) + "' on topic '"
          + msg.topic + "' with QoS " + str(msg.qos))
    print("User data " + str(userdata))
    print("Client " + client.client_id)

    # db.teste03.insert({
    # 	_id:
    # 	})

client_mqtt = mqtt.Client()
client_mqtt.on_connect = mqtt_connect
client_mqtt.on_message = mqtt_message

client_mqtt.connect("localhost", 1883, 60)

client_mqtt.loop_forever()
