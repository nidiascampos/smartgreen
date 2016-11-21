#include <Arduino.h>

// ** LIBRARIES **
// Watermark
/*
WM01      | WM02      | WM03
D4 -> A0  | D6 -> A2  | D8 -> A6
D5 -> A1  | D7 -> A3  | D9 -> A7
*/
#include <math.h> // Conversion equation from resistance to %
#include <SPI.h>

// ** PROJECT FILES **
#include "Watermark.h"
#include "Sleep.h"
#include "RF24module.h"

// Formato do output (CSV)
// (variância da leitura da resistência, leitura da resistência) * 3

void setup ()
{
  Serial.begin(57600);
  Serial.println("DEBUG: setup -> iniciando");

  // set sleep time in ms, max sleep time is 49.7 days
  sleepTime = 1800000; // 30 minutos (1000 * 60 * 30)
  // sleepTime = 60000; // 1 minuto

  // initialize the digital pins as an output.
  // Pin 4,5 is for sensor 1
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  // Pin 6,7 is for sensor 2
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  // Pin 8,9 is for sensor 3
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);

  // RF24
  client.setServer(server, 1883);
  client.setCallback(callback);
  Ethernet.begin(ip);
  Ethernet.set_gateway(gateway);
  if (mesh.begin()) {
    Serial.println(F("DEBUG: setup -> RF24 -> OK"));
  } else {
    Serial.println(F("DEBUG: setup -> RF24 -> falha"));
  }

  Serial.println("DEBUG: setup -> iniciado OK");
}

void loop ()
{
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  // make a string for assembling the data to log
  String dataString;

  // measure: sensor id, phase B pin, phase A pin, analog input pin
  measure(1,4,5,1);
  long read1 = average();
  measure(1,5,4,0);
  long read2= average();
  long sensor1 = (read1 + read2)/2;

  measure(2,6,7,3);
  long read3 = average();
  measure(2,7,6,2);
  long read4= average();
  long sensor2 = (read3 + read4)/2;

  measure(3,8,9,7);
  long read5 = average();
  measure(3,9,8,6);
  long read6= average();
  long sensor3 = (read5 + read6)/2;

  dataString += String(read1-read2); // resistance bias
  dataString += ",";
  dataString += String(sensor1); // sensor bias compensated value
  dataString += ",";
  dataString += String(read3-read4); // resistance bias
  dataString += ",";
  dataString += String(sensor2); // sensor bias compensated value
  dataString += ",";
  dataString += String(read5-read6); // resistance bias
  dataString += ",";
  dataString += String(sensor3); // sensor bias compensated value

  // DEBUG: print to the serial port
  Serial.println(dataString);

  // check connection and renew address (if needed)
  if( ! mesh.checkConnection() ){
    Serial.print("DEBUG: RF24 -> mesh -> conectando... ");
    mesh.renewAddress();
    Serial.println("OK");
  }

  if (!client.connected()) {
    reconnect();
  }

  Serial.println("DEBUG: RF24 -> MQTT -> enviando dados");
  char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  dataString.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/sensor/02",outputBuf);

  Serial.print("DEBUG: RF24 -> MQTT -> desconectando... ");
  client.disconnect();
  Serial.println("OK");
  delay(500); // delay necessário para o processo de desconexão

  // Sleep
  // prwDownMode: the most power saving, all systems are powered down
  // except the watch dog timer and external reset
  Serial.print("DEBUG: hibernando por ");
  Serial.print(sleepTime / 60000);
  Serial.print(" minuto(s)");
  delay(100); // delay to allow serial to fully print before sleep
  sleep.pwrDownMode(); // set sleep mode
  sleep.sleepDelay(sleepTime); // sleep for: sleepTime
}
