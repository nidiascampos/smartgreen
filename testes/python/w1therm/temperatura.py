import w1thermsensor
from w1thermsensor import W1ThermSensor

sensor = W1ThermSensor()
temp_celsius = sensor.get_temperature()
print(temp_celsius)
