import paho.mqtt.client as mqtt

def mqtt_connect(client, userdata, rc):
  print("Conectado com resultado "+str(rc))
  client.subscribe("outTopic/#")

def mqtt_message(client, userdata, msg):
  print(msg.topic+" "+str(msg.payload))

client = mqtt.Client()
client.on_connect = mqtt_connect
client.on_message = mqtt_message

client.connect("localhost", 1883, 60)

client.loop_forever()