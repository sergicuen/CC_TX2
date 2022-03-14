import sys
import RPi.GPIO as GPIO

Relay_Ch1 = 26
Relay_Ch2 = 20
Relay_Ch3 = 21

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

GPIO.setup(Relay_Ch1,GPIO.OUT)
GPIO.setup(Relay_Ch2,GPIO.OUT)
GPIO.setup(Relay_Ch3,GPIO.OUT)


GPIO.output(Relay_Ch3,GPIO.HIGH) 
GPIO.output(Relay_Ch2,GPIO.HIGH) 
GPIO.output(Relay_Ch1,GPIO.HIGH) 
print("RELE OFF")
