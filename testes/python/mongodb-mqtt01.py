import paho.mqtt.client as mqtt

def get_db():
  from pymongo import MongoClient
  client = MongoClient('localhost:27017')
  db = client.SmartGreen
  return db

def mqtt_connect(client, userdata, rc):
  print("Conectado com resultado "+str(rc))
  client.subscribe("/sensor/#")

# def add_message(db):
#   db.teste03.insert({"name": "Canada"})

def mqtt_message(client, userdata, msg):
  # print(msg.topic+" "+str(msg.payload))
  print("Received message '" + str(message.payload) + "' on topic '"
        + message.topic + "' with QoS " + str(message.qos))
  print("User data " + str(userdata));
  print("Client " + client.client_id);

  # db.teste03.insert({
  # 	_id: 
  # 	})

client = mqtt.Client()
client.on_connect = mqtt_connect
client.on_message = mqtt_message

client.connect("localhost", 1883, 60)

client.loop_forever()