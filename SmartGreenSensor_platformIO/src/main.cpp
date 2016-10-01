#include <Arduino.h>

// Watermark
#include <math.h> // Conversion equation from resistance to %
#include <SPI.h>

// SD output
// #include <SD.h> // FIXME: desabilitado temporariamente

// RTC
#include <avr/pgmspace.h>
#include <Wire.h> // must be incuded here so that Arduino library object file references work
#include <RtcDS3231.h>

// Arquivos do projeto
#include "RTC.h"
// #include "SD_output.h" // FIXME: desabilitado temporariamente
#include "Watermark.h"
#include "rain.h"

// Formato do output (CSV)
// ano, mês, dia, hora, minuto, segundo, temperatura,
// variância da leitura da resistência, leitura da resistência

void setup ()
{
  Serial.begin(57600);
  Serial.println("DEBUG: Iniciando...");

  // DEBUG: para informar quando o sketch foi compilado
  // Serial.print("compiled: ");
  // Serial.print(__DATE__);
  // Serial.println(__TIME__);

  // initialize the digital pins as an output.
  // Pin 6,7 is for sensor 1
  pinMode(4, OUTPUT); // Pin 6 is sense resistor voltage supply 1
  pinMode(5, OUTPUT); // Pin 7 is sense resistor voltage supply 2

  // pins for rain sensor
  // pinMode(rain_pin_digital, INPUT); // digital
  pinMode (rain_pin_analog, INPUT); // analog

  //--------RTC SETUP ------------
  Rtc.Begin();

  RtcDateTime compiled = RtcDateTime(__DATE__, __TIME__);
  // DEBUG: para informar quando o sketch foi compilado e a hora inicial que foi setada no RTC
  Serial.print("DEBUG: RTC -> Compilado em ");
  Serial.println(printDateTime(compiled)); // YYYY,MM,DD

  // Verificação se o RTC possui dados válidos
  Serial.print("DEBUG: RTC -> ");
  if (!Rtc.IsDateTimeValid())
  {
    // Common Causes:
    // 1) first time you ran and the device wasn't running yet
    // 2) the battery on the device is low or even missing
    Serial.println("RTC lost confidence in the DateTime!");

    // following line sets the RTC to the date & time this sketch was compiled
    // it will also reset the valid flag internally unless the Rtc device is
    // having an issue
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
  else if (now > compiled)
  {
    Serial.println("RTC is newer than compile time. (this is expected)");
  }
  else if (now == compiled)
  {
    Serial.println("RTC is the same as compile time! (not expected but all is fine)");
  }

  // never assume the Rtc was last configured by you, so
  // just clear them to your needed state
  Rtc.Enable32kHzPin(false);
  Rtc.SetSquareWavePin(DS3231SquareWavePin_ModeNone);

  // see if the card is present and can be initialized:
  /*
  Serial.print("DEBUG:  SD -> ");
  if (!SD.begin(chipSelect)) {
    Serial.println("Cartao SD falhou ou nao esta presente");
    // don't do anything more:
    return;
  }
  Serial.println("Cartao SD inicializado");
  */
}

void loop ()
{
  if (!Rtc.IsDateTimeValid())
  {
    // Common Cuases:
    // 1) the battery on the device is low or even missing and the power line was disconnected
    Serial.println("RTC lost confidence in the DateTime!");
  }

  RtcDateTime now = Rtc.GetDateTime();
  RtcTemperature temp = Rtc.GetTemperature();

  // make a string for assembling the data to log
  String dataString;

  // measure: sensor id, phase B pin, phase A pin, analog input pin
  measure(1,4,5,1);
  long read1 = average();
  measure(1,5,4,0);
  long read2= average();
  long sensor1 = (read1 + read2)/2;

  // check rain sensor
  int rainValue = detectRain();

  dataString += printDateTime(now); // current time (YYYY,MM,DD)
  dataString += ",";
  dataString += String(temp.AsFloat()); // temperature
  dataString += ",";
  dataString += String(rainValue); // rain sensor value
  dataString += ",";
  dataString += String(read1-read2); // resistance bias
  dataString += ",";
  dataString += String(sensor1); // sensor bias compensated value

  // DEBUG: print to the serial port
  Serial.print(dataString);
  Serial.println();

  // open the file:
  // File dataFile = SD.open("SGlog.csv", FILE_WRITE); // FIXME: desabilitado temporariamente

  // if the file is available, write to it:
  // FIXME: desabilitado temporariamente
  /*
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.close();
  }
  // if the file isn't open, pop up an error:
  else {
    Serial.println("Erro abrindo SGlog.csv");
  }
  */
  int minutes = 1;
  int waitTime = minutes * 10 * 1000;
  delay(waitTime);
}
