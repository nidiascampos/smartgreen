#include <Arduino.h>
#include <avr/pgmspace.h>
// Low Power
#include <LowPower.h>
// RTC
#include <Wire.h>  // must be incuded here so that Arduino library object file references work
#include <RtcDS3231.h>

void printDateTime(const RtcDateTime& dt);
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

void setup() {
  Serial.begin(57600);

  // set the interupt pin to input mode
  // This will consumes few uA of current.
  pinMode(RtcSquareWavePin, INPUT);

  Serial.println("Estou no setup");

  //--------RTC SETUP ------------
  Rtc.Begin();
  // if you are using ESP-01 then uncomment the line below to reset the pins to
  // the available pins for SDA, SCL
  // Wire.begin(0, 2); // due to limited pins, use pin 0 and 2 for SDA, SCL

  RtcDateTime compiled = RtcDateTime(__DATE__, __TIME__);

  if (!Rtc.IsDateTimeValid())
  {
    Serial.println("RTC lost confidence in the DateTime!");
    Rtc.SetDateTime(compiled);
  }

  if (!Rtc.GetIsRunning())
  {
    Serial.println("RTC was not actively running, starting now");
    Rtc.SetIsRunning(true);
  }

  RtcDateTime now = Rtc.GetDateTime();
  if (now < compiled)
  {
    Serial.println("RTC is older than compile time!  (Updating DateTime)");
    Rtc.SetDateTime(compiled);
  }

  Rtc.Enable32kHzPin(false);
  Rtc.SetSquareWavePin(DS3231SquareWavePin_ModeAlarmBoth);

  // Alarm 1 set to trigger every day when
  // the hours, minutes, and seconds match
  RtcDateTime alarmTime = now + 88; // into the future
  DS3231AlarmOne alarm1(
    alarmTime.Day(),
    alarmTime.Hour(),
    alarmTime.Minute(),
    alarmTime.Second(),
    DS3231AlarmOneControl_HoursMinutesSecondsMatch);
  Rtc.SetAlarmOne(alarm1);

  // Alarm 2 set to trigger at the top of the minute
  DS3231AlarmTwo alarm2(
    0, // day
    0, // hour
    30, // minute
    DS3231AlarmTwoControl_MinutesMatch);
  Rtc.SetAlarmTwo(alarm2);

  // throw away any old alarm state before we ran
  Rtc.LatchAlarmsTriggeredFlags();

  // setup external interupt
  attachInterrupt(RtcSquareWaveInterrupt, InteruptServiceRoutine, FALLING);
}

void loop() {
  if (!Rtc.IsDateTimeValid())
  {
      Serial.println("RTC lost confidence in the DateTime!");
  }

  RtcDateTime now = Rtc.GetDateTime();

  printDateTime(now);
  Serial.println();

  // we only want to show time every 10 seconds
  // but we want to show responce to the interupt firing
  // for (int timeCount = 0; timeCount < 20; timeCount++)
  // {
  //     if (Alarmed())
  //     {
  //         Serial.print(">>Interupt Count: ");
  //         Serial.print(interuptCount);
  //         Serial.println("<<");
  //     }
  //     delay(500);
  // }

  if (Alarmed())
  {
      Serial.print(">>Interupt Count: ");
      Serial.print(interuptCount);
      Serial.println("<<");
  }

  // Enter power down state with ADC and BOD module disabled.
  // Wake up when wake up pin is low.
  Serial.println("indo dormir");
  Serial.println();

  delay(500);

  // setting arduino into sleep/powerdown mode
  // ADC_OFF = disables ADC module
  // BOD_OFF = disables Brown Out Detector module
  // it will only wakeup via an interrupt trigger (even watchdog is disabled)
  LowPower.powerDown(SLEEP_FOREVER, ADC_OFF, BOD_OFF);
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

    if (flag & DS3231AlarmFlag_Alarm1)
    {
        Serial.println("alarm one triggered");
    }
    if (flag & DS3231AlarmFlag_Alarm2)
    {
        Serial.println("alarm two triggered !!!!!!!!!!!!!!!");
    }
  }
  return wasAlarmed;
}

#define countof(a) (sizeof(a) / sizeof(a[0]))

void printDateTime(const RtcDateTime& dt)
{
	char datestring[20];

	snprintf_P(datestring,
		countof(datestring),
		PSTR("%02u/%02u/%04u %02u:%02u:%02u"),
		dt.Month(),
		dt.Day(),
		dt.Year(),
		dt.Hour(),
		dt.Minute(),
		dt.Second() );
  Serial.print(datestring);
}
