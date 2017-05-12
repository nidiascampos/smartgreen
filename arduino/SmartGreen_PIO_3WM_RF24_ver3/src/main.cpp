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
#include "Sleep.h"
#include "batteryMonitor.h"
#include <printf.h>

// Structs --------------------------------------------------------------------
struct payload_t { // Payload data structure
  long wm15;
  long wm15bias;
  long wm45;
  long wm45bias;
  long wm75;
  long wm75bias;
  float vcc; // ou double
};

struct wmdata_t { // Watermark data structure
  long bias;
  long data;
};

// Function declarations ------------------------------------------------------
void sleepModule();
void battery_check();
void addReading(long resistance);
long average();
void measure(int phase_b, int phase_a, int analog_input);
wmdata_t wm_check(int phase_b, int phase_a, int analog_input_a, int analog_input_b);

// Radio Config ---------------------------------------------------------------
RF24 radio(2,10);                    // nRF24L01(+) radio attached using Getting Started board
RF24Network network(radio);          // Network uses that radio
const uint16_t this_node = 01;       // Address of our node in Octal format
const uint16_t other_node = 00;      // Address of the other node in Octal format

// Watermark Config -----------------------------------------------------------
// Setting up format for reading 3 soil sensors (FIXME: ajustar)
#define NUM_READS 10    // Number of sensor reads for filtering
const long knownResistor = 4700;  // Constant value of known resistor in Ohms
int supplyVoltage;                // Measured supply voltage
int sensorVoltage;                // Measured sensor voltage
int index;
int i;                            // Simple index variable
long buffer[NUM_READS];
String wmData;

// Setup ----------------------------------------------------------------------
void setup(void)
{
  Serial.begin(57600);
  Serial.print("*** SmartGreen - Module ID: ");
  Serial.print(this_node);
  Serial.println(" ***");

  // DEBUG
  // if the analog input pin is unconnected, random analog
  // noise will cause the call to randomSeed() to generate
  // different seed numbers each time the sketch runs.
  // randomSeed() will then shuffle the random function.
  // randomSeed(analogRead(4));

  //------------ SLEEP ------------
  // set sleep time in ms, max sleep time is 49.7 days
  // sleepTime = 60000; // 1 minuto
  // sleepTime = 300000; // 5 minutos
  // sleepTime = 900000; // 15 minutos
  sleepTime = 1800000; // 30 minutos (1000 * 60 * 30)
  // sleepTime = 3600000; // 1 hora

  //------------ PINS -------------
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

  //------------ RADIO ------------
  SPI.begin();
  radio.begin();

  // Format: channel, node address
  network.begin(90, this_node);

  // DEBUG
  // printf_begin();
  // radio.printDetails();
}

void loop() {

  //---------- WATERMARK ----------
  // Check watermark sensors
  wmdata_t wm15 = wm_check(4,5,0,1);
  wmdata_t wm45 = wm_check(6,7,2,3);
  wmdata_t wm75 = wm_check(8,9,6,7);

  // Serial.print("wm15 data: ");
  // Serial.print(wm15.data);
  // Serial.print(" | bias: ");
  // Serial.println(wm15.bias);

  // Serial.print("wm45 data: ");
  // Serial.print(wm45.data);
  // Serial.print(" | bias: ");
  // Serial.println(wm45.bias);

  // Serial.print("wm75 data: ");
  // Serial.print(wm75.data);
  // Serial.print(" | bias: ");
  // Serial.println(wm75.bias);

  //----------- BATTERY -----------
  float batteryVoltage = vcc.Read_Volts();

  //---------- SEND DATA ----------
  radio.powerUp(); // Turn on the radio
  delay(100);
  network.update(); // Check the network regularly

  payload_t payload = { wm15.data, wm15.bias, wm45.data, wm45.bias, wm75.data, wm75.bias, batteryVoltage };

  // Debug info
  Serial.print("Payload:");
  Serial.print(" wm15: ");
  Serial.print(payload.wm15);
  Serial.print(" , bias: ");
  Serial.print(payload.wm15bias);
  Serial.print(" | wm45: ");
  Serial.print(payload.wm45);
  Serial.print(" , bias: ");
  Serial.print(payload.wm45bias);
  Serial.print(" | wm75: ");
  Serial.print(payload.wm75);
  Serial.print(" , bias: ");
  Serial.print(payload.wm75bias);
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

wmdata_t wm_check(int phase_b, int phase_a, int analog_input_a, int analog_input_b) {
  // measure: phase B pin, phase A pin, analog input pin
  // measure(4,5,1);
  measure(phase_b, phase_a, analog_input_b);
  long read1 = average();
  // measure(5,4,0);
  measure(phase_a, phase_b, analog_input_a);
  long read2= average();
  long sensor = (read1 + read2)/2; // sensor bias compensated value
  long bias = read1 - read2; // resistance bias

  wmdata_t wmData = { bias, sensor };
  // DEBUG: gerando numeros aleatorios para simular leitura
  // wmdata_t wmData = {random(10,20), random(100,10000)};

  return wmData;
}

// Watermark Functions --------------------------------------------------------
void measure (int phase_b, int phase_a, int analog_input) {
  // read sensor, filter, and calculate resistance value
  // Noise filter: median filter

  for (i=0; i<NUM_READS; i++) {

    // Read 1 pair of voltage values
    digitalWrite(phase_a, HIGH); // set the voltage supply on
    delayMicroseconds(25);
    supplyVoltage = analogRead(analog_input); // read the supply voltage
    // Serial.print("supply voltage:");
    // Serial.println(supplyVoltage);
    delayMicroseconds(25);
    digitalWrite(phase_a, LOW); // set the voltage supply off
    delay(1);

    digitalWrite(phase_b, HIGH); // set the voltage supply on
    delayMicroseconds(25);
    sensorVoltage = analogRead(analog_input); // read the sensor voltage
    // Serial.print("sensor voltage: ");
    // Serial.println(sensorVoltage);
    delayMicroseconds(25);
    digitalWrite(phase_b, LOW); // set the voltage supply off

    // Calculate resistance
    // Tip: no need to transform 0-1023 voltage value to 0-5 range, due to following fraction
    long resistance = (knownResistor * (supplyVoltage - sensorVoltage ) / sensorVoltage);

    addReading(resistance);
    // Serial.println(resistance);
  }

}

void addReading(long resistance){
  buffer[index] = resistance;
  index++;
  if (index >= NUM_READS) index = 0;
}

long average(){
  long sum = 0;
  for (int i = 0; i < NUM_READS; i++){
    sum += buffer[i];
  }
  return (long)(sum / NUM_READS);
}
