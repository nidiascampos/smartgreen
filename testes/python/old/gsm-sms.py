import serial

ser = serial.Serial()
ser.baudrate = 19200
ser.port = "/dev/ttyAMA0"


ser.open()
ser.write(b'AT+CMGF=1\r')
ser.write(b'AT+CMGS="+5585981901528\r"')
ser.write(b'python')
ser.write(b'\x1A')
ser.close()
