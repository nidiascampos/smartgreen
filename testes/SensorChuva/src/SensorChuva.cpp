// baseado de http://www.arduinoecia.com.br/2014/06/sensor-de-chuva-arduino.html

#include <Arduino.h>

int pino_D = 2; // pino digital ligado ao D0 do sensor
int pino_A = A4; // pino analógico ligado ao A0 do sensor
int val_D = 0;
int val_A = 0;

void setup() {
  // definir os pinos do sensor como entrada
  pinMode(pino_D, INPUT);
  pinMode(pino_A, INPUT);

  Serial.begin(9600);
}

void loop() {
  // ler e armazenar o valor do pino digital
  val_D = digitalRead(pino_D);
  // ler e armazenar o valor do pino analogico
  // VCC 5v -> 1024 (seco) a 0 (muito molhado)
  // VCC 3.3v - > 740 (seco) a 0 (muito molhado)
  val_A = analogRead(pino_A);
  // enviar as informacoes para o monitor Serial
  Serial.print("Valor Digital: ");
  Serial.print(val_D);
  Serial.print(" / Valor Analogico: ");
  Serial.println(val_A);

  delay(1000);
}
