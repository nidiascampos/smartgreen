/*

   SD card attached to SPI bus as follows:
 ** MOSI - pin 11
 ** MISO - pin 12
 ** CLK - pin 13
 ** CS - pin 4

*/

#include <SD.h>

#define LIGHTPIN 0        // what pin the sensor is connected to

const int interval = 90 * 1000; // the interval between reads, in ms (definido como 90 seg)
long lastReadTime = 0;        // the last time you read the sensor, in ms

// On the Ethernet Shield, CS is pin 4. Note that even if it's not
// used as the CS pin, the hardware CS pin (10 on most Arduino boards,
// 53 on the Mega) must be left as an output or the SD library
// functions will not work.
const int chipSelect = 4;

void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  // definir PIN 13 como saida (led de debug)
  pinMode(13, OUTPUT);

  Serial.print("Initializing SD card...");

  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    return;
  }
  Serial.println("card initialized.");
}

void loop()
{
  // Get the current time in ms:
  long currentTime = millis();

  digitalWrite(13, HIGH);

  // make a string that start with a timestamp for assembling the data to log:
  String dataString;

  if (currentTime > lastReadTime + interval) {
    int lightsensor = analogRead(LIGHTPIN);
    dataString += String(lightsensor);
    dataString += ",";

    // open the file:
    File dataFile = SD.open("datalog.csv", FILE_WRITE);

    // if the file is available, write to it:
    if (dataFile) {
      dataFile.print(dataString);
      dataFile.close();
    }
    // if the file isn't open, pop up an error:
    else {
      Serial.println("error opening datalog.txt");
    }
    
    // print to the serial port too:
    Serial.print(dataString);
    lastReadTime = millis();
  }
}
