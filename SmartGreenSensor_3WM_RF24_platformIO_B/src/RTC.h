// CONNECTIONS:
// GND  --> GND
// VCC  --> 3.3v or 5.v
// SDA  --> Analog 4
// SCL  --> Analog 5
// SQW  --> Digital 2

#include <Arduino.h>
#include <avr/pgmspace.h>
// Low Power
#include <LowPower.h>
// RTC
#include <Wire.h>  // must be incuded here so that Arduino library object file references work
#include <RtcDS3231.h>

String printDateTime(const RtcDateTime& dt);
bool Alarmed();

// Use pin 2 as wake up pin
// const int wakeUpPin = 2;

RtcDS3231<TwoWire> Rtc(Wire);

// Interrupt Pin Lookup Table
// From: https://www.arduino.cc/en/Reference/AttachInterrupt
/*
Digital Pins Usable For Interrupts
Uno, Nano, Mini, other 328-based:	2, 3
Mega, Mega2560, MegaADK:	2, 3, 18, 19, 20, 21
Micro, Leonardo, other 32u4-based:	0, 1, 2, 3, 7
Zero: all digital pins, except 4
MKR1000 Rev.1:	0, 1, 4, 5, 6, 7, 8, 9, A1, A2
Due:	all digital pins
101:	all digital pins
*/
#define RtcSquareWavePin 2 // UNO or atmega328
#define RtcSquareWaveInterrupt 0 // UNO or atmega328

// marked volatile so interrupt can safely modify them and
// other code can safely read and modify them
volatile uint16_t interuptCount = 0;
volatile bool interuptFlag = false;

void wakeUp() {
  // Just a handler for the pin interrupt.
}

void InteruptServiceRoutine()
{
  // since this interupted any other running code,
  // don't do anything that takes long and especially avoid
  // any communications calls within this routine
  interuptCount++;
  interuptFlag = true;
}

bool Alarmed() {
  bool wasAlarmed = false;
  if (interuptFlag)  // check our flag that gets sets in the interupt
  {
    wasAlarmed = true;
    interuptFlag = false; // reset the flag

    // this gives us which alarms triggered and
    // then allows for others to trigger again
    DS3231AlarmFlag flag = Rtc.LatchAlarmsTriggeredFlags();

    // if (flag & DS3231AlarmFlag_Alarm1)
    // {
    //   Serial.println("DEBUG: alarm one triggered"); // FIXME: remove and disable alarm 1
    // }
    if (flag & DS3231AlarmFlag_Alarm2)
    {
      Serial.println("DEBUG: Waking up (Alarm 2)");
    }
  }
  return wasAlarmed;
}

#define countof(a) (sizeof(a) / sizeof(a[0]))

String printDateTime(const RtcDateTime& dt)
{
  char datestring[20];

  snprintf_P(datestring,
    countof(datestring),
    // PSTR("%02u/%02u/%04u %02u:%02u:%02u"),
    PSTR("%04u,%02u,%02u,%02u,%02u,%02u"), // (YYYY,MM,DD,hour,min,sec)
    dt.Year(),
    dt.Month(),
    dt.Day(),
    dt.Hour(),
    dt.Minute(),
    dt.Second()
  );

  return datestring;
}
