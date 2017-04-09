#include <Arduino.h>

// Arquivos do projeto
#include "Watermark.h"
#include "RF24module.h"
//#include "SD_output.h"

// Formato do output (CSV)
// ano, mês, dia, hora, minuto, segundo, temperatura,
// variância da leitura da resistência, leitura da resistência

void setup () 
{
  Serial.begin(57600);
  Serial.println("DEBUG: Iniciando...");

  // initialize the digital pins as an output.
  // Pin 6,7 is for sensor 1
  pinMode(6, OUTPUT); // Pin 6 is sense resistor voltage supply 1
  pinMode(7, OUTPUT); // Pin 7 is sense resistor voltage supply 2

  // RF24
  client.setServer(server, 1883);
  client.setCallback(callback);
  Ethernet.begin(ip);
  Ethernet.set_gateway(gateway);
  if (mesh.begin()) {
    Serial.println(F("DEBUG: RF24 -> OK"));
  } else {
    Serial.println(F("DEBUG: RF24 -> Failed"));
  }

  // see if the card is present and can be initialized:
  // Serial.print("DEBUG:  SD -> ");
  //  if (!SD.begin(chipSelect)) {
  //    Serial.println("Cartao SD falhou ou nao esta presente");
  //    // don't do anything more:
  //    return;
  //  }
  //  Serial.println("Cartao SD inicializado");
}

uint32_t mesh_timer = 0;

void loop () 
{
  
  if(millis()-mesh_timer > 60000){ //Every 60 seconds, test mesh connectivity and send data
    mesh_timer = millis();

    // check connection and renew address (if needed)
    if( ! mesh.checkConnection() ){
        mesh.renewAddress();
    }

    // make a string for assembling the data to log
    String sensorData, sensorBias, sensorReading;
  
    // measure: sensor id, phase B pin, phase A pin, analog input pin
    measure(1,6,7,1);
    long read1 = average();
    measure(1,7,6,0);
    long read2= average();
    long sensor1 = (read1 + read2)/2;
    
    sensorBias = String(read1-read2); // resistance bias
    sensorReading += String(sensor1); // sensor bias compensated value
    sensorData = sensorBias + "," + sensorReading;

    // open the file:
    // File dataFile = SD.open("SGlog.csv", FILE_WRITE);
  
    // if the file is available, write to it:
    //    if (dataFile) {
    //      dataFile.println(dataString);
    //      dataFile.close();
    //    }
    //    // if the file isn't open, pop up an error:
    //    else {
    //      Serial.println("Erro abrindo SGlog.csv");
    //    }
    
    // DEBUG: print to the serial port
    Serial.print(sensorData);
    Serial.println();
    char outputBuf[50]; // char array que serve como buffer da mensagem a ser enviada
    sensorBias.toCharArray(outputBuf, 50); // convertendo string 'dataString' para char (50 bytes) **FIXME: verificar valor tamanho ideal de bytes
    client.publish("outTopic/bias",outputBuf);
    sensorReading.toCharArray(outputBuf, 50);
    client.publish("outTopic/reading",outputBuf);
  } 
  
  if (!client.connected()) {
    reconnect();
  }

  client.loop();
}
