import os
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.IN)
state = GPIO.input(18)

if (state == 0):
    print("Chuva")
else:
    print("Sem chuva")
