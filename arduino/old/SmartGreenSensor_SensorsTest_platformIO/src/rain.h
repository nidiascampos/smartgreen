#include <Arduino.h>

// raindrop sensor pins
//int rain_pin_digital = 2;
int rain_pin_analog = A2;

// raindrop sensor values
//int rain_value_digital = 0;
int rain_value_analog = 0;

int detectRain() {
  // read and store digital pin value
  //rain_value_digital = digitalRead(rain_pin_digital);

  // read and store analog pin value
  // VCC 5v -> 1024 (dry) a 0 (very wet)
  // VCC 3.3v - > 740 (dry) a 0 (very wet)
  rain_value_analog = analogRead(rain_pin_analog);

  // print sensor values
  //Serial.print("Valor Digital: ");
  //Serial.print(rain_value_digital);
  Serial.print(" / Valor Analogico: ");
  Serial.println(rain_value_analog);

  return rain_value_analog;
}
