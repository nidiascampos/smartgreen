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
#include "batteryMonitor.h"

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

  Serial.println("DEBUG: setup -> concluido");
}

void loop ()
{
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  double batteryVoltage = vcc.Read_Volts();
  Serial.print("DEBUG: VCC   -> ");
  Serial.print(batteryVoltage);
  Serial.println(" Volts");

  // float batteryPercent = vcc.Read_Perc(VccMin, VccMax);
  // Serial.print(" / ");
  // Serial.print(batteryPercent);
  // Serial.println(" %");

  // make a string for assembling the data to log
  // String dataString;
  String wm01;
  String wm02;
  String wm03;
  String wm01bias;
  String wm02bias;
  String wm03bias;

  // measure: sensor id, phase B pin, phase A pin, analog input pin
  measure(1,4,5,1);
  long read1 = average();
  measure(1,5,4,0);
  long read2= average();
  long sensor1 = (read1 + read2)/2;
  wm01bias = String(read1-read2); // resistance bias
  wm01 = String (sensor1); // sensor bias compensated value

  measure(2,6,7,3);
  long read3 = average();
  measure(2,7,6,2);
  long read4= average();
  long sensor2 = (read3 + read4)/2;
  wm02bias = String(read3-read4); // resistance bias
  wm02 = String (sensor2); // sensor bias compensated value

  measure(3,8,9,7);
  long read5 = average();
  measure(3,9,8,6);
  long read6= average();
  long sensor3 = (read5 + read6)/2;
  wm03bias = String(read5-read6); // resistance bias
  wm03 = String (sensor3); // sensor bias compensated value

  // DEBUG: print to the serial port
  // Serial.print("wm01 data: ");
  // Serial.println(wm01);
  // Serial.print("bias: ");
  // Serial.println(wm01bias);
  // Serial.print("wm02 data: ");
  // Serial.println(wm02);
  // Serial.print("bias: ");
  // Serial.println(wm02bias);
  // Serial.print("wm03 data: ");
  // Serial.println(wm03);
  // Serial.print("bias: ");
  // Serial.println(wm03bias);

  // check connection and renew address (if needed)
  if( ! mesh.checkConnection() ){
    Serial.print("DEBUG: RF24  -> mesh -> conectando... ");
    mesh.renewAddress();
    Serial.println("OK");
  }

  if (!client.connected()) {
    reconnect();
  }

  Serial.println("DEBUG: RF24  -> MQTT -> enviando dados");
  // char array que serve como buffer da mensagem a ser enviada
  char outputBuf[10];
  // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  wm01.toCharArray(outputBuf, 10);
  client.publish("/sensor/03/wm01",outputBuf);
  wm01bias.toCharArray(outputBuf, 10);
  client.publish("/sensor/03/wm01bias",outputBuf);
  // delay(500);

  char outputBuf2[10];
  wm02.toCharArray(outputBuf2, 10);
  client.publish("/sensor/03/wm02",outputBuf2);
  wm02bias.toCharArray(outputBuf2, 10);
  client.publish("/sensor/03/wm02bias",outputBuf2);
  // delay(500);

  char outputBuf3[10];
  wm03.toCharArray(outputBuf3, 10);
  client.publish("/sensor/03/wm03",outputBuf3);
  wm03bias.toCharArray(outputBuf, 10);
  client.publish("/sensor/03/wm03bias",outputBuf3);
  // delay(500);

  char outputBuf4[10];
  char str_voltage[10];
  /* 4 is mininum width, 2 is precision; float value is copied onto str_temp*/
  dtostrf(batteryVoltage, 4, 2, str_voltage);
  sprintf(outputBuf4,"%s", str_voltage);
  // Serial.println(outputBuf4);
  client.publish("/sensor/03/vcc",outputBuf4);

  Serial.print("DEBUG: RF24  -> MQTT -> desconectando... ");
  client.disconnect();
  Serial.println("OK");
  delay(500); // delay necessário para o processo de desconexão

  // Sleep
  // prwDownMode: the most power saving, all systems are powered down
  // except the watch dog timer and external reset
  Serial.print("DEBUG: hibernando por ");
  Serial.print(sleepTime / 60000);
  Serial.println(" minuto(s)");
  delay(100); // delay to allow serial to fully print before sleep
  sleep.pwrDownMode(); // set sleep mode
  sleep.sleepDelay(sleepTime); // sleep for: sleepTime
}
