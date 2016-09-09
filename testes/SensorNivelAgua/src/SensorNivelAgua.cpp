// baseado de http://www.arduinoecia.com.br/2014/07/arduino-sensor-de-nivel-de-liquidos.html
// usar resistencia de 470, 1k ou 10k para fazer pull-down

#include <Arduino.h>

int pinoSensor = 3; // pino digital ligado ao sensor

void setup() {
  Serial.begin(9600);
  pinMode(pinoSensor, INPUT);
}

void loop() {
  int estado = digitalRead(pinoSensor);
  Serial.print("Estado do Sensor: ");
  Serial.println(estado);

  delay(1000); // 1s
}
