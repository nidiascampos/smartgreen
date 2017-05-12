/*
 Copyright (C) 2012 James Coliz, Jr. <maniacbug@ymail.com>

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 version 2 as published by the Free Software Foundation.

 Update 2014 - TMRh20
 Update 2016 - Andrei Bosco
 */

#include <Arduino.h>
#include <RF24Network.h>
#include <RF24.h>
#include <SPI.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "Sleep.h"
#include "batteryMonitor.h"
#include <printf.h>

// Structs --------------------------------------------------------------------
struct payload_t { // Payload data structure
  float vcc; // ou double
  float temperature;
  long rain_analog;
  bool rain_digital;
};

// Function declarations ------------------------------------------------------
void sleepModule();
void battery_check();
void temperature_sensor_address(DeviceAddress deviceAddress);

// Temperature Sensor Config (DS18B20) -----------------------------------------
#define ONE_WIRE_BUS 3
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
DeviceAddress sensor1;
float temperatureVal = 0;

// Rain Sensor Config ---------------------------------------------------------
int nRainIn = A0;
int nRainDigitalIn = 9;
int rainValAnalog;
bool rainValDigital;

// Radio Config ---------------------------------------------------------------
// RF24 radio(7,8);                  // nRF24L01(+) radio
RF24 radio(2,10);                  // nRF24L01(+) radio
RF24Network network(radio);        // Network uses that radio
const uint16_t this_node = 05;     // Address of our node in Octal format
const uint16_t other_node = 00;    // Address of the other node in Octal format

// Setup ----------------------------------------------------------------------
void setup(void)
{
  Serial.begin(57600);
  Serial.print("*** SmartGreen - Module ID: ");
  Serial.print(this_node);
  Serial.println(" ***");

  //------------ SLEEP ------------
  // set sleep time in ms, max sleep time is 49.7 days
  // sleepTime = 10000; // 10 segundos
  // sleepTime = 60000; // 1 minuto
  // sleepTime = 300000; // 5 minutos
  // sleepTime = 900000; // 15 minutos
  sleepTime = 1800000; // 30 minutos (1000 * 60 * 30)
  // sleepTime = 3600000; // 1 hora

  //------------ PINS -------------
  // initialize the digital pins as an output.
  // rain sensor
  pinMode(nRainDigitalIn,INPUT);
  pinMode(nRainIn,INPUT);
  // temperature sensor
  sensors.begin();
  // Localiza e mostra enderecos dos sensores
  Serial.println("Detecting DS18B20 sensors...");;
  Serial.print(sensors.getDeviceCount(), DEC);
  Serial.println(" sensor found.");
  if (!sensors.getAddress(sensor1, 0))
     Serial.println("!! No sensor found !!");
  // Mostra o endereco do sensor encontrado no barramento
  Serial.print("Sensor addr: ");
  temperature_sensor_address(sensor1);
  Serial.println();

  //------------ RADIO ------------
  SPI.begin();
  radio.begin();
  // Format: channel, node address
  network.begin(90, this_node);
  // Debug radio details
  printf_begin();
  radio.printDetails();
}

void loop() {

  //---------- SENSORS ----------
  // Check rain drop status
  rainValAnalog = analogRead(nRainIn);
  rainValDigital = !(digitalRead(nRainDigitalIn));
  // Check temperature
  sensors.requestTemperatures();
  float temperatureVal = sensors.getTempC(sensor1);

  //----------- BATTERY -----------
  float batteryVoltage = vcc.Read_Volts();

  //---------- SEND DATA ----------
  radio.powerUp(); // Turn on the radio
  delay(100);
  network.update(); // Check the network regularly

  payload_t payload = { batteryVoltage, temperatureVal, rainValAnalog, rainValDigital };

  // Debug info
  Serial.print("Payload:");
  Serial.print(" rain analog: ");
  Serial.print(payload.rain_analog);
  Serial.print(" , digital: ");
  Serial.print(payload.rain_digital);
  Serial.print(" | temperature: ");
  Serial.print(payload.temperature);
  Serial.print(" | vcc: ");
  Serial.println(payload.vcc);
  Serial.print("Sending...");

  RF24NetworkHeader header(/*to node*/ other_node);

  bool ok = network.write(header,&payload,sizeof(payload));
  if (ok)
    Serial.println("Ok.");
  else
    Serial.println("Failed."); // FIXME: tentar fazer com que ele tente reenviar em caso de erro

  radio.powerDown(); // Turn off radio to save power

  //---------- SLEEP -----------
  sleepModule();
}

void sleepModule() {
  // Enter power down state with ADC and BOD module disabled.
  // Wake up when wake up pin is low.
  Serial.print("Sleeping for ");
  Serial.print(sleepTime / 60000);
  Serial.println(" minute(s) \n");

  delay(500); // delay to allow serial to fully print before sleep

  sleep.pwrDownMode(); // set sleep mode
  sleep.sleepDelay(sleepTime); // sleep for: sleepTime
}

void temperature_sensor_address(DeviceAddress deviceAddress)
{
  for (uint8_t i = 0; i < 8; i++)
  {
    // Adiciona zeros se necessário
    if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
}
