// CONNECTIONS:
// nRF24 GND  --> GND
// nRF24 VCC  --> 3.3v
// nRF24 CE   --> Digital 8
// nRF24 CSN  --> Digital 9
// nRF24 SCK  --> Digital 13
// nRF24 MOSI --> Digital 11
// nRF24 MISO --> Digital 12
// nRF24 IRQ  --> -

RF24 radio(8,9);
RF24Network network(radio);
RF24Mesh mesh(radio,network);
RF24EthernetClass RF24Ethernet(radio,network,mesh);

IPAddress ip(10,10,2,7);
IPAddress gateway(10,10,2,2); //Specify the gateway in case different from the server
IPAddress server(10,10,2,2);

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i=0;i<length;i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

EthernetClient ethClient;
PubSubClient client(ethClient);

void reconnect() {
  // Loop until we're reconnected
  if (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("arduinoClient")) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish("outTopic","connected");
      // ... and resubscribe
      client.subscribe("inTopic");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
