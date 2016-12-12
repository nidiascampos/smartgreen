import w1thermsensor
from w1thermsensor import W1ThermSensor


def temperatura():
  sensor = W1ThermSensor()
  temp_celsius = sensor.get_temperature()
  return
