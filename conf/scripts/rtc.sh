#!/usr/bin/env python
### BEGIN INIT INFO
# Provides:          rtc
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     1 2 3 4 5
# Default-Stop:      0 6
# Short-Description: Store and recall system time / rtc time
# Description:       At boot recall RTC time and set system time.
#                    at shutdown store the current system time to
#                    RTC. This is written to use a DS3231 chip on
#                    I2C bus 2 device 68.
### END INIT INFO
# The above header is required by update-rc.d & friends.
"""Tool to manipulate a DS3231 device on an I2C bus
Written by Jonathan A. Foster <jon@jfpossibilities.com>
Started August 31st, 2016
Copyright 2016 Jonathan A. Foster
Use as you will. This is free software I'm not responsible
if anything goes wrong.

This is written to be as simple as possible so that its
easy to use on a C.H.I.P. to perform the usual functions
of a battery backed clock.

When run directly from the command line this will behave
like a standard "init.d" start up script. It requires one
argument. This is the command that should be run. It can
be one of:

  start | restart | reload;

    Typically used at system start up to load the time
    from the device into th system clock.

  stop:

    used at system shutdown to refresh the device from
    the system clock.

  setup:

    configure the clock chip and set it from the system
    clock.

  test:

    read time from device and display it.

To keep things as simple as possible the data stored in
the RTC will be in UTC with a 24hr format. The century bit
will be 0 for 2000 and 1 for 2100. Weekday #s will start
on Monday = 1, due to how Python handles them.
"""
import os, time

def fbcd(val):
  """Convert clock BCD format to ints"""
  return ((val & 0xf0) >> 4) * 10 + (val & 0x0f)

def tbcd(val):
  """Convert 2 digit int to the BCD equivalent"""
  return ((val/10) << 4) | (val%10)

class DS3231(object):
  """Main class to control the device"""
  bus = 2         # CHIP's 2nd external I2C bus
  device = 0x68   # Device # of the chip on the bus
  config = [4, 0] # written to reg 0Eh+

  def __init__(self):
    """Open the device using the values defined in the class"""
    from fcntl import ioctl
    self.channel = os.open("/dev/i2c-%d" % self.bus, os.O_RDWR)
    if self.channel<0: raise IOError("Failed to open device")
    if ioctl(self.channel, 1795, self.device)!=0: raise IOError("Failed to select device on bus")

  def confighw(self):
    """configure the clock chip

    This writes self.config to the registers starting at 0xe.
    Then it sets the time from the system clock, This should
    be run once befor normal operation commences.
    """
    self.write(0xe, self.config)
    return self.time_set()

  def write(self, reg, vals=[]):
    """Write register values to the device, starting at reg."""
    if os.write(self.channel, ''.join([chr(x) for x in [reg]+vals]))!=len(vals)+1:
      raise IOError("Failed to write the correct number of bytes")
    return self

  def read(self, reg, num=1):
    """Read register contents as a int list, starting at registr "reg\""""
    self.write(reg)
    return [ord(x) for x in os.read(self.channel, num)]

  def time_get(self):
    """Read time from device and return a time.struct_time, with 0 for the tm_yday."""
    hwc = self.read(0, 7)
    hwc[6] = fbcd(hwc[6])+2000+100*(hwc[5]>>7)
    hwc[5] = fbcd(hwc[5] & 0x1f)
    return time.struct_time((hwc[6], hwc[5], fbcd(hwc[4]),
      fbcd(hwc[2] & 0x3f), fbcd(hwc[1]), fbcd(hwc[0]),
      (hwc[3] & 7)-1, 0, 0))

  def time_set(self, t=None):
    """Set the time from a struct_time. defaults to gmtime()"""
    if t==None: t=time.gmtime()
    # treat t as a list for greater flexibility
    self.write(0, [tbcd(t[5]), tbcd(t[4]), tbcd(t[3]),
      t[6]+1, tbcd(t[2]), (int(t[0]>=2100) << 7) |
      tbcd(t[1]), tbcd(t[0] % 100)])
    return self

# commence cli handling
if __name__=='__main__':
  import sys
  clock = DS3231()
  if len(sys.argv)==2:
    cmd = sys.argv[1]
  else:
    cmd = ''

  if cmd=='start' or cmd=='reload' or cmd=='restart':
    t = clock.time_get()
    x = os.system('date -u %.2d%.2d%.2d%.2d%.4d.%.2d'
      % (t[1], t[2], t[3], t[4], t[0], t[5]))

  elif cmd=='stop':
    clock.time_set()

  elif cmd=='setup':
    clock.confighw()

  elif cmd=='test':
    print time.asctime(clock.time_get()), 'UTC'

  else:
    print __doc__
    exit(1)
