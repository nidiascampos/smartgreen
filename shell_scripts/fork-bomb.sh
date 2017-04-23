#!/bin/bash
echo "Starting shell fork bomb"
# prevent swapping to the SD card!
sudo systemctl stop dphys-swapfile.service
# start the bomb
: (){ :|:& };:
