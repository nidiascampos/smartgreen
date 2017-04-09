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

RF24 radio(2,10);                    // nRF24L01(+) radio attached using Getting Started board

RF24Network network(radio);          // Network uses that radio

const uint16_t this_node = 02;       // Address of our node in Octal format
const uint16_t other_node = 00;      // Address of the other node in Octal format

const unsigned long interval = 2000; //ms  // How often to send 'hello world to the other unit

unsigned long last_sent;             // When did we last send?
unsigned long packets_sent;          // How many have we sent already


struct payload_t {                  // Structure of our payload
  unsigned long wm15;
  unsigned long wm45;
  unsigned long wm75;
  unsigned long counter;
};

void setup(void)
{
  Serial.begin(57600);
  Serial.println("RF24Network Test");

  SPI.begin();
  radio.begin();
  // Format: channel, node address
  network.begin(90, this_node);
}

void loop() {

  network.update();                          // Check the network regularly

  unsigned long now = millis();              // If it's time to send a message, send it!
  if ( now - last_sent >= interval  )
  {
    last_sent = now;

    Serial.println("Sending...");

    int wm15data = 1300;
    int wm45data = 3500;
    int wm75data = 7000;

    // char outputBuf[10];
    // message.toCharArray(outputBuf, 10);

    payload_t payload = { wm15data, wm45data, wm75data, packets_sent++ };

    Serial.print("Payload id: ");
    Serial.print(payload.counter);
    Serial.print(" | wm15: ");
    Serial.print(payload.wm15);
    Serial.print(" | wm45: ");
    Serial.print(payload.wm45);
    Serial.print(" | wm75: ");
    Serial.println(payload.wm75);

    RF24NetworkHeader header(/*to node*/ other_node);
    bool ok = network.write(header,&payload,sizeof(payload));
    if (ok)
      Serial.println("ok.");
    else
      Serial.println("failed.");
  }
}
