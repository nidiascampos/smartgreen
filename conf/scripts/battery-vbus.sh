#!/bin/sh
# This program gets the battery info from PMU
# Voltage and current charging/discharging
#
# Nota : temperature can be more than real because of self heating
#######################################################################
# Copyright (c) 2014 by RzBo, Bellesserre, France
#
# Permission is granted to use the source code within this
# file in whole or in part for any use, personal or commercial,
# without restriction or limitation.
#
# No warranties, either explicit or implied, are made as to the
# suitability of this code for any purpose. Use at your own risk.
#######################################################################
# Original source: https://bbs.nextthing.co/t/updated-battery-sh-dumps-limits-input-statuses/2921

# set ADC enabled for all channels
ADC=$(i2cget -y -f 0 0x34 0x82)
# if couldn't perform get, then exit immediately
[ $? -ne 0 ] && exit $?

if [ "$ADC" != "0xff" ] ; then
    i2cset -y -f 0 0x34 0x82 0xff
    # Need to wait at least 1/25s for the ADC to take a reading
    sleep 1
fi

################################
#read Power status register @00h
POWER_STATUS=$(i2cget -y -f 0 0x34 0x00)

# echo -n "Battery current direction = "
# [ $(($POWER_STATUS & 0x04)) -ne 0 ] && echo "Charging" \
    # || echo "Discharging"

###################
#read internal temperature 	5eh, 5fh	-144.7c -> 000h,	0.1c/bit	FFFh -> 264.8c
TEMP_MSB=$(i2cget -y -f 0 0x34 0x5e)
TEMP_LSB=$(i2cget -y -f 0 0x34 0x5f)

TEMP_BIN=$(( ($TEMP_MSB << 4) | ($TEMP_LSB & 0x0F) ))

TEMP_C=$(echo "$TEMP_BIN*0.1-144.7"|bc)
 # echo "Internal temperature = "$TEMP_C"c"

###################
#read VBUS information
if [ $(($POWER_STATUS & 0x20)) -ne 0 ] ; then
    # echo "VBUS present"
    VBIN_VOLT_MSB=$(i2cget -y -f 0 0x34 0x5a)
    VBIN_VOLT_LSB=$(i2cget -y -f 0 0x34 0x5b)
    VBIN_BIN=$(( ($VBIN_VOLT_MSB << 4) | ($VBIN_VOLT_LSB & 0x0F) ))
    VBIN_VOLT=$(echo "$VBIN_BIN*1.7"|bc)
    # echo "  VBUS voltage = "$VBIN_VOLT"mV"

    VBIN_I_MSB=$(i2cget -y -f 0 0x34 0x5c)
    VBIN_I_LSB=$(i2cget -y -f 0 0x34 0x5d)
    VBIN_I_BIN=$(( ($VBIN_I_MSB << 4) | ($VBIN_I_LSB & 0x0F) ))
    VBIN_I=$(echo "$VBIN_I_BIN*0.375"|bc)
    # echo "  VBUS current = "$VBIN_I"mA"
else
    VBIN_VOLT=0
    VBIN_I=0
    # echo "VBUS not present"
fi

# VBUS_IPSOUT=$(i2cget -y -f 0 0x34 0x30)

# VBUS_V_LIMIT=$(($VBUS_IPSOUT >> 3 & 0x07))
# VBUS_V_LIMIT=$(echo "scale=2;$VBUS_V_LIMIT*0.10+4.00"|bc)
# [ $(($VBUS_IPSOUT & 0x40)) -ne 0 ] && VBUS_V_LIMIT_E="Enabled" \
    # || VBUS_V_LIMIT_E="Disabled"
# echo "  VBUS voltage limit = "$VBUS_V_LIMIT"V ("$VBUS_V_LIMIT_E")"

# VBUS_I_LIMIT=$((VBUS_IPSOUT & 3))
# echo -n "  VBUS current limit = "
# case $VBUS_I_LIMIT in
#   0) echo "900mA";;
#   1) echo "500mA";;
#   2) echo "100mA";;
#   3) echo "~spooky~ unlimited";;
#   *) echo "?";;
# esac

echo $TEMP_C","$VBIN_VOLT","$VBIN_I
