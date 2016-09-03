// CONNECTIONS:
// DS3231 SDA --> SDA (A4 no uno)
// DS3231 SCL --> SCL (A5 no uno)
// DS3231 VCC --> 3.3v or 5v
// DS3231 GND --> GND

#include <Arduino.h>
#include <RtcDS3231.h>

#define countof(a) (sizeof(a) / sizeof(a[0]))

RtcDS3231 Rtc;

String printDateTime(const RtcDateTime& dt)
{
  char datestring[20];

  snprintf_P(datestring, 
          countof(datestring),
          PSTR("%04u,%02u,%02u,%02u,%02u,%02u"),
          dt.Year(),
          dt.Month(),
          dt.Day(),
          dt.Hour(),
          dt.Minute(),
          dt.Second() );

  return datestring;
}
