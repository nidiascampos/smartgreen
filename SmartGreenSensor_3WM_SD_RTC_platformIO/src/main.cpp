#include <Arduino.h>

// ** PROJECT FILES **
#include "RTC.h"
#include "batteryMonitor.h"
#include "SD_output.h"

void rtc_check();
void battery_check();
String wm_check();
void sd_write();
void sleep();

void addReading(long resistance);
long average();
void measure(int sensor, int phase_b, int phase_a, int analog_input);

String dataString;

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
String wmRead;

void setup () {
  Serial.begin(57600);
  Serial.println("DEBUG: Setup -> Starting");

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

void loop () {
  delay(100); // (sleep) delays are just for serial print, without serial they can be removed

  //----------- RTC ------------
  rtc_check();

  //------ BatteryMonitor ------
  battery_check();

  //----------- WM -------------
  wmRead = wm_check();
  Serial.print("wms: ");
  Serial.println(wmRead);

  //----------- SD -------------
  sd_write();

  //---------- SLEEP -----------
  sleep();
}

void rtc_check() {
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

  if (Alarmed())
  {
      Serial.print(">>Interupt Count: ");
      Serial.print(interuptCount);
      Serial.println("<<");
  }
}

String wm_check() {
  // make a string for assembling the data to log
  String wmData;

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
  wmData.concat(rawData);

  Serial.print("15cm: ");
  Serial.println(wmData);

  rawData = "";

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
  dataString += wmData;
  dataString += ",";

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
  dataString += wmData;
  dataString += ",";

  return wmData;
}

void battery_check() {
  double batteryVoltage = vcc.Read_Volts();
  Serial.print("DEBUG: VCC   -> ");
  Serial.print(batteryVoltage);
  Serial.println(" Volts");
  dataString += batteryVoltage; // FIXME: test code
  dataString += ","; // FIXME: test code
}

void sd_write() {
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
}

void sleep() {
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

// ** WATERMARK FUNCTIONS **
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

void measure (int sensor, int phase_b, int phase_a, int analog_input) {
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

  Serial.print("raw data: ");
  Serial.println(rawData);
}
