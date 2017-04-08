#include <Arduino.h>
#include <SPI.h>
#include <printf.h>
#include "RF24.h"

// CONFIG
// Set this radio as radio number 0 or 1
bool radioNumber = 0;

// Hardware configuration: Set up nRF24L01 radio on SPI bus plus pins 2 & 10
RF24 radio(2,10);
/**********************************************************/

void setup() {
  // Open Serial Communication
  Serial.begin(115200);
  Serial.println(F("TESTE DE COMUNICACAO"));

  // Radio Settings
  radio.begin();
  radio.setChannel(120); // Communication Channel: 0 - 124
  radio.setCRCLength(RF24_CRC_8); // CRC: 1 = 8 bits, 2 = 16 bits
  radio.setPALevel(RF24_PA_MAX); // RF24_PA_MIN, RF24_PA_LOW, RF24_PA_HIGH and RF24_PA_MAX
  radio.setDataRate(RF24_1MBPS); // 0 = RF24_1MBPS for 1Mbps, 1 = RF24_2MBPS for 2Mbps, 2 = RF24_250KBPS for 250kbs
  radio.setAutoAck(1); // ACK: 1 = Enable, 0 = Disable
  radio.setRetries(15,15); // Set the number and delay of retries upon failed submit

  // Print radio settings.
  printf_begin();
  radio.printDetails();

  // Start the radio listening for data
  radio.startListening();
}

void loop() {
  // radio.stopListening(); // First, stop listening so we can talk
  // Serial.println(F("Now sending"));
  // String payload = "teste";
  // if (!radio.write(&payload, sizeof(payload)) ) {
  //   Serial.println(F("falha"));
  // }
  //
  // radio.startListening(); // Now, continue listening

/****************** Ping Out Role ***************************/


  radio.stopListening();                                    // First, stop listening so we can talk.

  unsigned long start_time = micros();                             // Take the time, and send it.  This will block until complete
  Serial.print(F("Sending payload: "));
  Serial.println(start_time);
  Serial.print(F("Payload size: "));
  Serial.println(sizeof(unsigned long));
   if (!radio.write( &start_time, sizeof(unsigned long) )){
     Serial.println(F("failed"));
   }

  radio.startListening();                                    // Now, continue listening

  unsigned long started_waiting_at = micros();               // Set up a timeout period, get the current microseconds
  boolean timeout = false;                                   // Set up a variable to indicate if a response was received or not

  while ( ! radio.available() ){                             // While nothing is received
    if (micros() - started_waiting_at > 400000 ){            // If waited longer than 400ms, indicate timeout and exit while loop
        timeout = true;
        break;
    }
  }

  if ( timeout ){                                             // Describe the results
      Serial.println(F("Failed, response timed out."));
  }else{
      unsigned long got_time;                                 // Grab the response, compare, and send to debugging spew
      radio.read( &got_time, sizeof(unsigned long) );
      unsigned long end_time = micros();

      // Spew it
      Serial.print(F("Sent "));
      Serial.print(start_time);
      Serial.print(F(", Got response "));
      Serial.print(got_time);
      Serial.print(F(", Round-trip delay "));
      Serial.print(end_time-start_time);
      Serial.println(F(" microseconds"));
  }

  // Try again 5s later
  delay(5000);


} // Loop
