#include <Arduino.h>

// Watermark
#include <math.h> // Conversion equation from resistance to %
#include <SPI.h>
/*
WM01      | WM02      | WM03
D4 -> A0  | D6 -> A2  | D8 -> A6
D5 -> A1  | D7 -> A3  | D9 -> A7
*/

// SD output
#include <SD.h>

// Sleep
#include <Sleep_n0m1.h>

// Arquivos do projeto
#include "SD_output.h"
#include "Watermark.h"
#include "Sleep.h"

// SIM900
// #include "SIM900.h"

// Formato do output (CSV)
// ano, mês, dia, hora, minuto, segundo, temperatura,
// leitura da resistência, leitura compensada da resistência * 3, variancia da leitura

void setup ()
{
  Serial.begin(57600);
  // Serial.println("DEBUG: Iniciando...");

  // set sleep time in ms, max sleep time is 49.7 days
  sleepTime = 1800000; // 45 minutos (1000 * 60 * 30)
  // int minutes = 1;
  // sleepTime = minutes * 60 * 1000;

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

  // see if the card is present and can be initialized:
  Serial.print("DEBUG:  SD -> ");
  if (!SD.begin(chipSelect)) {
    Serial.println("Cartao SD falhou ou nao esta presente");
    // don't do anything more:
    return;
  }
  Serial.println("Cartao SD inicializado");

  // SIM900 modem
  // powerOnSIM900();
  // Serial.println("Conectando à rede da operadora");
  // while( sendATcommand2("AT+CREG?", "+CREG: 0,1", "+CREG: 0,5", 1000)== 0 );
}

void loop ()
{
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  // make a string for assembling the data to log
  String dataString;

  // measure: sensor id, phase B pin, phase A pin, analog input pin 0, analog input pin 1
  measureSensor(1,4,5,0,1);
  // measure(1,4,5,1);
  // long read1 = average();
  // measure(1,5,4,0);
  // long read2= average();
  // long sensor1 = (read1 + read2)/2;
  // long variance1 = variance(sensor1);

  // measure(2,6,7,3);
  // long read3 = average();
  // measure(2,7,6,2);
  // long read4= average();
  // long sensor2 = (read3 + read4)/2;
  // long variance2 = variance(sensor2);
  //
  // measure(3,8,9,7);
  // long read5 = average();
  // measure(3,9,8,6);
  // long read6= average();
  // long sensor3 = (read5 + read6)/2;
  // long variance3 = variance(sensor3);

  // dataString += String(read1); // resistance bias
  // dataString += ",";
  // dataString += String(read2); // resistance bias
  // dataString += ",";
  // dataString += String(read1-read2); // resistance bias
  // dataString += ",";

  for (size_t i = 1; i < 4; i++) {
    dataString += String(sensor[i]); // sensor bias compensated value
    dataString += ",";
    dataString += String(variance[i]); // sensor reading variance
    dataString += ",";
    dataString += String(sqrt(variance[i])); // sensor standard deviation
  }


  // dataString += ",";
  // dataString += String(read3-read4); // resistance bias
  // dataString += ",";
  // dataString += String(sensor2); // sensor bias compensated value
  // dataString += ",";
  // dataString += String(variance2); // sensor reading variance
  // dataString += ",";
  // dataString += String(read5-read6); // resistance bias
  // dataString += ",";
  // dataString += String(sensor3); // sensor bias compensated value
  // dataString += ",";
  // dataString += String(variance3); // sensor reading variance

  // SIM900
  // long sensorsData[3] = {sensor1, sensor2, sensor3};
  // Serial.print("sensors data: ");
  // Serial.println(sensorsData[0]);
  // Serial.println(sensorsData[1]);
  // Serial.println(sensorsData[2]);
  // sendDataToCloud(sensorsData);
  // powerDownSIM900();

  // DEBUG: print to the serial port
  Serial.print(dataString);
  Serial.println();

  // SD
  // open the file:
  File dataFile = SD.open("SGlog.csv", FILE_WRITE);
  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.close();
  }
  // if the file isn't open, pop up an error:
  else {
    Serial.println("Erro abrindo SGlog.csv");
  }

  // Sleep
  // Serial.print("sleeping for ");
  // Serial.println(sleepTime);
  // delay(100); // delay to allow serial to fully print before sleep
  // **prwDownMode**
  // The most power saving, all systems are powered down
  // except the watch dog timer and external reset
  sleep.pwrDownMode(); // set sleep mode
  sleep.sleepDelay(sleepTime); // sleep for: sleepTime

  // int minutes = 1;
  // int waitTime = minutes * 60 * 1000;
  // delay(waitTime);
}
