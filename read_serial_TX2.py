############################################################################
# read_serial_cna.py
# last update: 14/02/2022
# description: Control de benchmark execution
#	- SUT board is conected to Relay_Ch1
#	- register the messages coming via serial
# 	- if the time between sucessive msg is greater wait_time,
#	  a reboot is forced via power_off/on	
# usage:  while true ; do python3 read_serial_mod.py ; done
#
############################################################################

import serial
import sys 
import time
import RPi.GPIO as GPIO
from datetime import datetime

Relay_Ch1 = 26
Relay_Ch2 = 20
Relay_Ch3 = 21

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

GPIO.setup(Relay_Ch1,GPIO.OUT)
#GPIO.setup(Relay_Ch2,GPIO.OUT)
#GPIO.setup(Relay_Ch3,GPIO.OUT)

# Activate Relay_Ch1
#GPIO.output(Relay_Ch1,GPIO.HIGH) 
#GPIO.output(Relay_Ch1,GPIO.HIGH) 
GPIO.output(Relay_Ch1,GPIO.LOW) #START
time.sleep(5)

ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=60)
filename = "../Raspi_Results" + datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S.%f')[:-3] + "_save_results.csv"
print("THE CONNECTION IS OPEN")
last_time = time.time()
wait_time = 2*60 
while True:
    line = ser.readline()   # read a '\n' terminated line
    #print(line)
    if line:
        last_time = time.time()
        string = line.decode("utf-8") 
        file = open(filename,"a")
        file.write(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
        file.write("\t")
        file.write(string)
        file.write("\n")
        #print(string)
        file.close()
    elif (time.time()-last_time) > wait_time:
        file = open(filename,"a")
        file.write(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3])
        file.write("\t")        
        file.write("potential hang")
        file.write("\n")
        #print("potential hang \n")
        file.close()
        GPIO.output(Relay_Ch1,GPIO.HIGH) #STOP
        #time.sleep(5)
        #GPIO.output(Relay_Ch1,GPIO.HIGH) #STOP
        sys.exit(1)

file.close()
