#include <Arduino.h>

// ** LIBRARIES **
// Watermark
/*
WM01      | WM02      | WM03
D4 -> A0  | D6 -> A2  | D8 -> A6
D5 -> A1  | D7 -> A3  | D9 -> A7
*/
#include <math.h> // Conversion equation from resistance to %
#include <SPI.h>

// ** PROJECT FILES **
// #include "Watermark.h"
#include "Sleep.h"
#include "RF24module.h"
#include "batteryMonitor.h"
#include "RTC.h"

// ** WATERMARK CONFIG **
// Setting up format for reading 3 soil sensors (FIXME: ajustar)
#define NUM_READS 5    // Number of sensor reads for filtering

typedef struct {        // Structure to be used in percentage and resistance values matrix to be filtered (have to be in pairs)
  int moisture;
  long resistance;
} values;

const long knownResistor = 4700;  // Constant value of known resistor in Ohms

int supplyVoltage;                // Measured supply voltage
int sensorVoltage;                // Measured sensor voltage

values valueOf[NUM_READS];        // Calculated moisture percentages and resistances to be sorted and filtered
long buffer[NUM_READS];
int index;

int i;                            // Simple index variable

String rawData;
bool rawDataReset;

// ** WATERMARK FUNCTIONS **
// Averaging algorithm
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

void measure (int sensor, int phase_b, int phase_a, int analog_input)
{
  // read sensor, filter, and calculate resistance value
  // Noise filter: median filter

  for (i=0; i<NUM_READS; i++) {

    // Read 1 pair of voltage values
    digitalWrite(phase_a, HIGH);                 // set the voltage supply on
    delayMicroseconds(25);
    supplyVoltage = analogRead(analog_input);   // read the supply voltage
    // Serial.print("supply voltage:");
    // Serial.println(supplyVoltage);
    delayMicroseconds(25);
    digitalWrite(phase_a, LOW);                  // set the voltage supply off
    delay(1);

    digitalWrite(phase_b, HIGH);                 // set the voltage supply on
    delayMicroseconds(25);
    sensorVoltage = analogRead(analog_input);   // read the sensor voltage
    // Serial.print("sensor voltage: ");
    // Serial.println(sensorVoltage);
    delayMicroseconds(25);
    digitalWrite(phase_b, LOW);                  // set the voltage supply off

    // Calculate resistance
    // the 0.5 add-term is used to round to the nearest integer
    // Tip: no need to transform 0-1023 voltage value to 0-5 range, due to following fraction
    long resistance = (knownResistor * (supplyVoltage - sensorVoltage ) / sensorVoltage) ;

    delay(1);
    addReading(resistance);
    // Serial.println(resistance);

    // if (rawDataReset == true) {
    //   rawData = resistance;
    // } else {
    //   rawData.concat(resistance);
    // }
    rawData.concat(resistance);
    // if (i == NUM_READS-1 ) {
    //
    // } else {
    //   rawData.concat(",");
    // }
    rawData.concat(",");
    // Serial.print ("\t");
  }
  // rawDataReset = false;

  // Serial.print("raw data: ");
  // Serial.println(rawData);
}

// ** SETUP **
void setup ()
{
  Serial.begin(57600);
  // Serial.println("DEBUG: setup -> iniciando");

  //------------ SLEEP ------------
  // set sleep time in ms, max sleep time is 49.7 days
  sleepTime = 1800000; // 30 minutos (1000 * 60 * 30)
  // sleepTime = 60000; // 1 minuto

  //------------ PINS ------------
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

  //------------ RTC ------------
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

  //------------ RF24 ------------
  client.setServer(server, 1883);
  client.setCallback(callback);
  Ethernet.begin(ip);
  Ethernet.set_gateway(gateway);
  if (mesh.begin()) {
    Serial.println(F("DEBUG: setup -> RF24 -> OK"));
  } else {
    Serial.println(F("DEBUG: setup -> RF24 -> falha"));
  }

  // Serial.println("DEBUG: setup -> iniciado OK");
}

// ** LOOP **
void loop ()
{
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  if (!Rtc.IsDateTimeValid())
  {
    // Common Cuases:
    // 1) the battery on the device is low or even missing and the power line was disconnected
    Serial.println("RTC lost confidence in the DateTime!");
  }

  RtcDateTime now = Rtc.GetDateTime();
  RtcTemperature temp = Rtc.GetTemperature();

  Serial.print("DEBUG: Date -> ");
  Serial.println(printDateTime(now)); // current time (YYYY,MM,DD))
  Serial.print("DEBUG: Temp -> ");
  Serial.println(temp.AsFloat());

  double batteryVoltage = vcc.Read_Volts();
  Serial.print("DEBUG: VCC   -> ");
  Serial.print(batteryVoltage);
  Serial.println(" Volts");

  // make a string for assembling the data to log
  String wmData;
  // String wm01raw, wm02raw, wm03raw;

  // check connection and renew address (if needed)
  if( ! mesh.checkConnection() ){
    Serial.print("DEBUG: RF24  -> mesh -> conectando... ");
    mesh.renewAddress();
    Serial.println("OK");
  }

  if (!client.connected()) {
    reconnect();
  }

  // measure: sensor id, phase B pin, phase A pin, analog input pin
  measure(1,4,5,1);
  long read1 = average();
  measure(1,5,4,0);
  long read2= average();
  long sensor1 = (read1 + read2)/2;

  wmData = String(read1-read2); // resistance bias
  wmData += ",";
  wmData += String(sensor1); // sensor bias compensated value
  wmData += ",";
  wmData += rawData;
  rawData = "";

  // Serial.print("DEBUG: RF24 -> MQTT -> enviando dados: ");
  Serial.print("15cm: ");
  Serial.println(wmData);

  char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  wmData.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/04/15",outputBuf);

  measure(2,6,7,3);
  long read3 = average();
  measure(2,7,6,2);
  long read4= average();
  long sensor2 = (read3 + read4)/2;

  wmData = String(read3-read4); // resistance bias
  wmData += ",";
  wmData += String(sensor2); // sensor bias compensated value
  wmData += ",";
  wmData += rawData;
  rawData = "";

  Serial.print("45cm: ");
  Serial.println(wmData);

  // char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  wmData.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/04/45",outputBuf);

  measure(3,8,9,7);
  long read5 = average();
  measure(3,9,8,6);
  long read6= average();
  long sensor3 = (read5 + read6)/2;

  wmData = String(read5-read6); // resistance bias
  wmData += ",";
  wmData += String(sensor3); // sensor bias compensated value
  wmData += ",";
  wmData += rawData;
  rawData = "";

  Serial.print("75cm: ");
  Serial.println(wmData);

  // char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  wmData.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/04/75",outputBuf);

  char outputBuf4[10];
  char str_voltage[10];
  /* 4 is mininum width, 2 is precision; float value is copied onto str_temp*/
  dtostrf(batteryVoltage, 4, 2, str_voltage);
  sprintf(outputBuf4,"%s", str_voltage);
  // Serial.println(outputBuf4);
  client.publish("/04/vcc",outputBuf4);

  Serial.print("vcc: ");
  Serial.println(outputBuf4);

  // Serial.print("DEBUG: RF24 -> MQTT -> desconectando... ");
  client.disconnect();
  // Serial.println("OK");
  delay(500); // delay necessário para o processo de desconexão

  // Sleep
  // prwDownMode: the most power saving, all systems are powered down
  // except the watch dog timer and external reset
  Serial.print("DEBUG: hibernando por ");
  Serial.print(sleepTime / 60000);
  Serial.print(" minuto(s)");
  delay(100); // delay to allow serial to fully print before sleep
  sleep.pwrDownMode(); // set sleep mode
  sleep.sleepDelay(sleepTime); // sleep for: sleepTime
}
