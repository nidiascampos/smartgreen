// CONNECTIONS:
// nRF24 GND  --> GND
// nRF24 VCC  --> 3.3v
// nRF24 CE   --> Digital 2
// nRF24 CSN  --> Digital 3
// nRF24 SCK  --> Digital 13
// nRF24 MOSI --> Digital 11
// nRF24 MISO --> Digital 12
// nRF24 IRQ  --> -

// RF24
#include <SPI.h>
#include <RF24.h>
#include <RF24Network.h>
#include <RF24Mesh.h>
#include <RF24Ethernet.h>
#include <PubSubClient.h>

RF24 radio(2,3);
RF24Network network(radio);
RF24Mesh mesh(radio,network);
RF24EthernetClass RF24Ethernet(radio,network,mesh);

// IPs
// sensor1: 9 (mini) - ok
// sensor2: 8 (mini) - ok (WM3 estranho)
// sensor3: 6 (mini) - ok (WM3 estranho)
// sensor4: 7 (nano) - ok (WMs ok)
// #define nodeID 9 // FIXME: tentar implementar esse metodo
IPAddress ip(10,10,2,7);
IPAddress gateway(10,10,2,2); //Specify the gateway in case different from the server
IPAddress server(10,10,2,2);

EthernetClient ethClient;
PubSubClient client(ethClient);

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Mensagem recebida [");
  Serial.print(topic);
  Serial.print("] ");
  for (unsigned int i=0;i<length;i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

void reconnect() {
  // Loop until we're reconnected
  if (!client.connected()) {
    Serial.print("DEBUG: RF24  -> MQTT -> conectando... ");
    // Attempt to connect
    if (client.connect("sensor04")) { // clientID, willTopic, willQoS, willRetain, willMessage
      Serial.println("OK");
      // Once connected, publish an announcement...
      // client.publish("/sensor/02","connected");
      // ... and resubscribe
      // client.subscribe("inTopic");
    } else {
      Serial.print("falha, rc=");
      Serial.print(client.state());
      Serial.println(" tentando novamente em 5 segundos");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
