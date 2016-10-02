#include <Arduino.h>

#include <OneWire.h>
#include <DallasTemperature.h>

void mostra_endereco_sensor(DeviceAddress DeviceAddress);

// Porta do pino de sinal do DS18B20
#define ONE_WIRE_BUS 3

// Define uma instancia do oneWire para comunicacao com o sensor
OneWire oneWire(ONE_WIRE_BUS);

// Declarando as funções
void mostra_endereco_sensor(DeviceAddress deviceAddress);

DallasTemperature sensors(&oneWire);
DeviceAddress sensor1;

void mostra_endereco_sensor(DeviceAddress deviceAddress)
{
  for (uint8_t i = 0; i < 8; i++)
  {
    // Adiciona zeros se necessário
    if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
}
