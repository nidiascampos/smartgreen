#!/usr/bin/python
#-------------------------------------------------------------------------------
# Name:        fork.bomb
# Purpose:
#
# Author:      paulv
#
# Created:     09-05-2016
# Copyright:   (c) paulv 2016
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import os
import subprocess

def main():
    print "fork bomb starting"
    # prevent swapping to the SD card!
    subprocess.call(['sudo systemctl stop dphys-swapfile.service'], shell=True, \
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    while True:
        os.fork()

if __name__ == '__main__':
    main()
