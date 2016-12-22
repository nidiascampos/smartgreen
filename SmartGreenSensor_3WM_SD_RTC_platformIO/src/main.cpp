#include <Arduino.h>

// ** PROJECT FILES **
#include "RTC.h"
#include "batteryMonitor.h"
#include "SD_output.h"

void rtc_loop();

String dataString; // FIXME: test code

// ** SETUP **
void setup ()
{
  Serial.begin(57600);
  Serial.println("DEBUG: Setup -> Starting");

  //------------ RTC ------------
  // set the interupt pin to input mode
  // This will consumes few uA of current.
  pinMode(RtcSquareWavePin, INPUT);

  Rtc.Begin();

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

  // Alarm 2 set to trigger at the top of the minute
  // DS3231AlarmTwoControl_MinutesMatch: triggers once an hour when the minute matched
  DS3231AlarmTwo alarm2(
    0, // day
    0, // hour
    20, // minute
    DS3231AlarmTwoControl_MinutesMatch);
  Rtc.SetAlarmTwo(alarm2);

  // throw away any old alarm state before we ran
  Rtc.LatchAlarmsTriggeredFlags();

  // setup external interupt
  attachInterrupt(RtcSquareWaveInterrupt, InteruptServiceRoutine, FALLING);

  //------------ SD ------------
  // see if the card is present and can be initialized:
  Serial.print("DEBUG: SD    -> ");
  if (!SD.begin(chipSelect)) {
    Serial.println("SD failed or not found");
    // don't do anything more:
    return;
  }
  Serial.println("SD card initialized");

  Serial.println("DEBUG: Setup -> OK");
}

// ** LOOP **
void loop ()
{
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  rtc_loop();

  if (Alarmed())
  {
      Serial.print(">>Interupt Count: ");
      Serial.print(interuptCount);
      Serial.println("<<");
  }

  //------------ BatteryMonitor ------------
  double batteryVoltage = vcc.Read_Volts();
  Serial.print("DEBUG: VCC   -> ");
  Serial.print(batteryVoltage);
  Serial.println(" Volts");
  dataString += batteryVoltage; // FIXME: test code
  dataString += ","; // FIXME: test code

  //------------ SD ------------
  // open the file:
  File dataFile = SD.open("WMlog.csv", FILE_WRITE);
  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.close();
  }
  // if the file isn't open, pop up an error:
  else {
    Serial.println("Error opening WMlog.csv");
  }

  // Enter power down state with ADC and BOD module disabled.
  // Wake up when wake up pin is low.
  Serial.println("DEBUG: Going into sleep");
  Serial.println();

  delay(500);

  // setting arduino into sleep/powerdown mode
  // ADC_OFF = disables ADC module
  // BOD_OFF = disables Brown Out Detector module
  // it will only wakeup via an interrupt trigger (even watchdog is disabled)
  LowPower.powerDown(SLEEP_FOREVER, ADC_OFF, BOD_OFF);
}

void rtc_loop() {
  if (!Rtc.IsDateTimeValid())
  {
    // Common Causes:
    // 1) the battery on the device is low or even missing and the power line was disconnected
    Serial.println("RTC lost confidence in the DateTime!");
  }

  RtcDateTime now = Rtc.GetDateTime();
  RtcTemperature temp = Rtc.GetTemperature();

  Serial.print("DEBUG: Time  -> ");
  Serial.println(printDateTime(now));
  dataString += printDateTime(now); // FIXME: test code
  dataString += ","; // FIXME: test code

  Serial.print("DEBUG: Temp  -> ");
  Serial.println(temp.AsFloat());
  dataString += String(temp.AsFloat()); // FIXME: test code
  dataString += ","; // FIXME: test code
}
