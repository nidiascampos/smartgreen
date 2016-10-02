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
#include "rain.h"
#include "temperature.h"

// Formato do output (CSV)
// ano, mês, dia, hora, minuto, segundo, temperatura,
// variância da leitura da resistência, leitura da resistência

void setup ()
{
  Serial.begin(57600);
  Serial.println("DEBUG: Iniciando...");
  sensors.begin();

  // Localiza e mostra enderecos dos sensores
  Serial.println("Localizando sensores DS18B20...");
  Serial.print("Foram encontrados ");
  Serial.print(sensors.getDeviceCount(), DEC);
  Serial.println(" sensores.");
  if (!sensors.getAddress(sensor1, 0))
     Serial.println("Sensores nao encontrados !");
  // Mostra o endereco do sensor encontrado no barramento
  Serial.print("Endereco sensor: ");
  mostra_endereco_sensor(sensor1);
  Serial.println();

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

  // make a string for assembling the data to log
  String dataString;

  // check rain sensor
  int rainValue = detectRain();

  // check temperature sensor
  sensors.requestTemperatures();
  float tempC = sensors.getTempC(sensor1);

  // organizing data output
  dataString += printDateTime(now); // current time (YYYY,MM,DD)
  dataString += ",";
  dataString += String(tempC); // temperature
  dataString += ",";
  dataString += String(rainValue); // rain sensor value

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
