import serial

ser = serial.Serial()
ser.baudrate = 19200
ser.port = "/dev/ttyAMA0"

def power_on_sim900:
    ser.write(b'AT\r')
    ser.write(b'AT+CSCLK=0\r')
    ser.write(b'AT+CFUN=1\r')
    # FIXME: continuar

ser.open()
ser.write(b'AT+CMGF=1\r')
ser.write(b'AT+CMGS="+5585981901528\r"')
ser.write(b'python')
ser.write(b'\x1A')
ser.close()
