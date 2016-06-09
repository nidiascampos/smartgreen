// Watermark
#include <math.h> // Conversion equation from resistance to %
#include <SPI.h>

// RF24
#include <SPI.h>
#include <RF24.h>
#include <RF24Network.h>
#include <RF24Mesh.h>
#include <RF24Ethernet.h>
#include <PubSubClient.h>

// Arquivos do projeto
#include "Watermark.h"
#include "RF24module.h"

// Formato do output (CSV)
// ano, mês, dia, hora, minuto, segundo, temperatura,
// variância da leitura da resistência, leitura da resistência

void setup () 
{
  Serial.begin(57600);
  Serial.println("DEBUG: Iniciando...");

  // initialize the digital pins as an output.
  // Pin 6,7 is for sensor 1
  pinMode(6, OUTPUT); // Pin 6 is sense resistor voltage supply 1
  pinMode(7, OUTPUT); // Pin 7 is sense resistor voltage supply 2

  // RF24
  client.setServer(server, 1883);
  client.setCallback(callback);
  Ethernet.begin(ip);
  Ethernet.set_gateway(gateway);
  if (mesh.begin()) {
    Serial.println(F("DEBUG: RF24 -> OK"));
  } else {
    Serial.println(F("DEBUG: RF24 -> Failed"));
  }
}

uint32_t mesh_timer = 0;

void loop () 
{
  if (millis()-mesh_timer > 60000) {
    // make a string for assembling the data to log
    String dataString;
  
    // measure: sensor id, phase B pin, phase A pin, analog input pin
    measure(1,6,7,1);
    long read1 = average();
    measure(1,7,6,0);
    long read2= average();
    long sensor1 = (read1 + read2)/2;
    
    dataString += String(read1-read2); // resistance bias
    dataString += ",";
    dataString += String(sensor1); // sensor bias compensated value
    
    // DEBUG: print to the serial port
    Serial.print(dataString);
    Serial.println();
    if (client.connect("arduinoClient")) {
      client.publish("outTopic","teste"); 
    }
  }
  

  // RF24
  if(millis()-mesh_timer > 30000){ //Every 30 seconds, test mesh connectivity
    mesh_timer = millis();
    if( ! mesh.checkConnection() ){
        mesh.renewAddress();
     }
  } 
  
  if (!client.connected()) {
    reconnect();
  }

  client.loop();

  //delay(60000); // sixty seconds
}
