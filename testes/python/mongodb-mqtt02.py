import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
from pymongo import MongoClient


def mqtt_connect(client, userdata, rc):
    print("Connected with result: "+str(rc))
    client.subscribe("/#")


def mqtt_message(client, userdata, msg):
    print("Received message '" + str(msg.payload) + "' on topic '"
          + msg.topic + "' with QoS " + str(msg.qos))
    mongo_add_message(msg)


def mongo_add_message(msg):
    import datetime
    # splitting sensor data
    data_list = msg.payload.split(',')
    data_vcc = data_list.pop(22)
    data_std = data_list.pop(21)
    data_average = data_list.pop(20)
    # splitting topic info
    topic_list = msg.topic.split('/')
    sensor_id = topic_list[1]
    sensor_depth = topic_list[2]
    # inserting data into mongodb
    db.teste04.insert({
        "sensor": sensor_id,
        "depth": sensor_depth,
        "when": datetime.datetime.utcnow(),
        "average": data_average,
        "STD": data_std,
        "raw": tuple(data_list),
        "vcc": data_vcc
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

# ADAFRUIT
adafruit_mqtt = mqtt.Client()
adafruit_mqtt.on_connect = mqtt_connect
adafruit_mqtt.username_pw_set("andreibosco", "f38fefdd1fa94e2aaec9fd857b036e19")
adafruit_mqtt.connect("io.adafruit.com", 1883, 60)

publish.single("andreibosco/f/WM_01_45", "25",
               hostname="io.adafruit.com",
               port=1883,
               auth={'username': 'andreibosco', 'password':'f38fefdd1fa94e2aaec9fd857b036e19'})
