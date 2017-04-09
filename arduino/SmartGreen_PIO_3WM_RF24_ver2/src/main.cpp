#include <Arduino.h>

// ** PROJECT FILES **
#include "RF24module.h"
#include "batteryMonitor.h"
#include "Sleep.h"
// #include <LowPower.h>

void battery_check();
void wm_check(int phase_b, int phase_a, int analog_input_a, int analog_input_b);
void sleepModule();

void addReading(long resistance);
long average();
void measure(int phase_b, int phase_a, int analog_input);

// String basicData;
bool printDebug;

// ** WATERMARK CONFIG **
// Setting up format for reading 3 soil sensors (FIXME: ajustar)
#define NUM_READS 11    // Number of sensor reads for filtering

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
String wmData;

void setup () {
  Serial.begin(57600);

  printDebug = true;
  // Serial.println("DEBUG: Setup -> Starting");

  //------------ SLEEP ------------
  // set sleep time in ms, max sleep time is 49.7 days
  // sleepTime = 1800000; // 30 minutos (1000 * 60 * 30)
  // sleepTime = 60000; // 1 minuto
  // sleepTime = 300000; // 5 minutos
  sleepTime = 900000; // 15 minutos

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

}

void loop () {
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  radio.powerUp();

  //------ BatteryMonitor ------
  battery_check();

  // DEBUG
  // if (printDebug == 1) {
  //     Serial.print("basic data: ");
  //     Serial.println(basicData);
  //     basicData = "";
  // }

  //------- RF24 CONNECT -------
  // check connection and renew address (if needed)
  if( ! mesh.checkConnection() ){
    Serial.print("DEBUG: RF24  -> mesh -> conectando... ");
    mesh.renewAddress();
    Serial.println("OK");
  }

  if (!client.connected()) {
    reconnect();
  }

  //---------- WM 01 -----------
  wm_check(4,5,0,1);
  // Serial.print("DEBUG: RF24 -> MQTT -> enviando dados: ");

  char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  wmData.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/03/15",outputBuf);

  //---------- WM 02 -----------
  wm_check(6,7,2,3);

  // char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  wmData.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/03/45",outputBuf);

  //---------- WM 03 -----------
  wm_check(8,9,6,7);

  // char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
  wmData.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
  client.publish("/03/75",outputBuf);

  //---------  BATTERY ---------
  double batteryVoltage = vcc.Read_Volts();
  char outputBuf4[10];
  char str_voltage[10];
  /* 4 is mininum width, 2 is precision; float value is copied onto str_temp*/
  dtostrf(batteryVoltage, 4, 2, str_voltage);
  sprintf(outputBuf4,"%s", str_voltage);
  // // Serial.println(outputBuf4);
  client.publish("/03/vcc",outputBuf4);
  if (printDebug) {
    Serial.print("vcc: ");
    Serial.println(outputBuf4);
  }

  //----- RF 24 DISCONNECT -----
  // Serial.print("DEBUG: RF24 -> MQTT -> desconectando... ");
  client.disconnect();
  // Serial.println("OK");
  delay(500); // delay necessário para o processo de desconexão

  radio.powerDown();

  //---------- SLEEP -----------
  sleepModule();
}

void wm_check(int phase_b, int phase_a, int analog_input_a, int analog_input_b) {
  rawData = ""; // resetting rawData

  // measure: phase B pin, phase A pin, analog input pin
  // measure(4,5,1);
  measure(phase_b, phase_a, analog_input_b);
  long read1 = average();
  // measure(5,4,0);
  measure(phase_a, phase_b, analog_input_a);
  long read2= average();
  long sensor1 = (read1 + read2)/2;

  wmData = String(read1-read2); // resistance bias
  wmData += ",";
  wmData += String(sensor1); // sensor bias compensated value
  // wmData += ",";

  // DEBUG
  if (printDebug == 1) {
    Serial.print("wm data: ");
    Serial.println(wmData);
  }

}

void battery_check() {
  double batteryVoltage = vcc.Read_Volts();
  // Serial.print("DEBUG: VCC   -> ");
  // Serial.print(batteryVoltage);
  // Serial.println(" Volts");
  // basicData += batteryVoltage;
}

void sleepModule() {
  // Enter power down state with ADC and BOD module disabled.
  // Wake up when wake up pin is low.
  if (printDebug == 1) {
    Serial.print("DEBUG: Sleeping for ");
    Serial.print(sleepTime / 60000);
    Serial.println(" minute(s)");
  }

  delay(500); // delay to allow serial to fully print before sleep

  sleep.pwrDownMode(); // set sleep mode
  sleep.sleepDelay(sleepTime); // sleep for: sleepTime
}

// ** WATERMARK FUNCTIONS **
void measure (int phase_b, int phase_a, int analog_input) {
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
    // Tip: no need to transform 0-1023 voltage value to 0-5 range, due to following fraction
    long resistance = (knownResistor * (supplyVoltage - sensorVoltage ) / sensorVoltage);
    // test
    // valueOf[i].resistance = long( float(knownResistor) * ( supplyVoltage - sensorVoltage ) / sensorVoltage);
    // valueOf[i].moisture = min( int( pow( valueOf[i].resistance/31.65 , 1.0/-1.695 ) * 400 + 0.5 ) , 100 );

    // delay(1);
    addReading(resistance);
    // Serial.println(resistance);

    rawData.concat(resistance);
    rawData.concat(",");

    // test
    // Serial.print("resistencia: ");
    // Serial.println(valueOf[i].resistance);
    // Serial.print("umidade: ");
    // Serial.print(valueOf[i].moisture);
    // Serial.println();
  }

  // Print out median values -- test
  // Serial.print("resistencia: ");
  // Serial.println(valueOf[NUM_READS/2].resistance);
  // Serial.print("umidade: ");
  // Serial.print(valueOf[NUM_READS/2].moisture);
  // Serial.println();

  // DEBUG
  // Serial.print("raw measure: ");
  // Serial.println(rawData);
}

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
