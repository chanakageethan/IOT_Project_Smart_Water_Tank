import RPi.GPIO as gpio
import time
import paho.mqtt.client as mqtt
gpio.setmode(gpio.BCM)


TRIG = 23 
ECHO = 24

gpio.setup(TRIG,gpio.OUT)
gpio.setup(ECHO,gpio.IN)


def on_connect(client,userdata,flags,rc):
     print("connected with result code ",rc)

def getLevel():
    firstTime = True
    maxHeight = 0
    distance = 0
    pulse_duration = 0
    pulse_start =0 
    pulse_end = 0 
    try:
        while True:
            gpio.output(TRIG,False)
            # print "Waiting for Sensor to settle"
            time.sleep(2)

            gpio.output(TRIG,True)
            # time.sleep(0.00001)
            time.sleep(0.00002)
            gpio.output(TRIG,False)

            while gpio.input(ECHO)==0:
                pulse_start = time.time()

            while gpio.input(ECHO)==1:
                pulse_end = time.time()

            pulse_duration = pulse_end - pulse_start
            distance = pulse_duration * 17150
            distance = round(distance,1)
            
            if  firstTime == True:
                print("========")
                maxHeight = distance
                firstTime = False
            
            value  = ((maxHeight - distance ) /   maxHeight ) * 100
            print   "============================"
            print   "max height : ", maxHeight
            print   "Distance :", distance
          
            if value < 0  or  value < 1   :
                value = 0 
            else:
                value = value    

            print    value , " %"


            # =====================================================================
            client = mqtt.Client("Python_as_Client")
            client.on_connect = on_connect
            client.connect("broker.emqx.io",1883,60)
            client.publish('Mysensor', payload=int(value), qos=0,retain=False)
            print  "Sending ......"
            time.sleep(1)
            # =====================================================================
 
    except KeyboardInterrupt:
        print("Cleaning up!") 
        gpio.cleanup()  















getLevel()

    
     



               