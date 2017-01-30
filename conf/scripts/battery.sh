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

echo -n "Battery current direction = "
[ $(($POWER_STATUS & 0x04)) -ne 0 ] && echo "Charging" \
    || echo "Discharging"

################################
#read Power OPERATING MODE register @01h
POWER_OP_MODE=$(i2cget -y -f 0 0x34 0x01)

echo -n "Charging indicator = " 
[ $(($POWER_OP_MODE & 0x40)) -ne 0 ] && echo "Charging" \
    || echo "Not charging or charging completed"

###################
#read internal temperature 	5eh, 5fh	-144.7c -> 000h,	0.1c/bit	FFFh -> 264.8c
TEMP_MSB=$(i2cget -y -f 0 0x34 0x5e)
TEMP_LSB=$(i2cget -y -f 0 0x34 0x5f)

TEMP_BIN=$(( ($TEMP_MSB << 4) | ($TEMP_LSB & 0x0F) ))

TEMP_C=$(echo "$TEMP_BIN*0.1-144.7"|bc)
echo "Internal temperature = "$TEMP_C"c"

###################
#read ACIN information
if [ $(($POWER_STATUS & 0x80)) -ne 0 ] ; then
    echo "ACIN present"
    ACIN_VOLT_MSB=$(i2cget -y -f 0 0x34 0x56)
    ACIN_VOLT_LSB=$(i2cget -y -f 0 0x34 0x57)
    ACIN_BIN=$(( ($ACIN_VOLT_MSB << 4) | ($ACIN_VOLT_LSB & 0x0F) ))
    ACIN_VOLT=$(echo "$ACIN_BIN*1.7"|bc)
    echo "  ACIN voltage = "$ACIN_VOLT"mV"

    ACIN_I_MSB=$(i2cget -y -f 0 0x34 0x58)
    ACIN_I_LSB=$(i2cget -y -f 0 0x34 0x59)
    ACIN_I_BIN=$(( ($ACIN_I_MSB << 4) | ($ACIN_I_LSB & 0x0F) ))
    ACIN_I=$(echo "$ACIN_I_BIN*0.625"|bc)
    echo "  ACIN current = "$ACIN_I"mA"
else
    echo "ACIN not present"
fi

###################
#read VBUS information
if [ $(($POWER_STATUS & 0x20)) -ne 0 ] ; then
    echo "VBUS present"
    VBIN_VOLT_MSB=$(i2cget -y -f 0 0x34 0x5a)
    VBIN_VOLT_LSB=$(i2cget -y -f 0 0x34 0x5b)
    VBIN_BIN=$(( ($VBIN_VOLT_MSB << 4) | ($VBIN_VOLT_LSB & 0x0F) ))
    VBIN_VOLT=$(echo "$VBIN_BIN*1.7"|bc)
    echo "  VBUS voltage = "$VBIN_VOLT"mV"

    VBIN_I_MSB=$(i2cget -y -f 0 0x34 0x5c)
    VBIN_I_LSB=$(i2cget -y -f 0 0x34 0x5d)
    VBIN_I_BIN=$(( ($VBIN_I_MSB << 4) | ($VBIN_I_LSB & 0x0F) ))
    VBIN_I=$(echo "$VBIN_I_BIN*0.375"|bc)
    echo "  VBUS current = "$VBIN_I"mA"
else
    echo "VBUS not present"
fi

VBUS_IPSOUT=$(i2cget -y -f 0 0x34 0x30)

VBUS_V_LIMIT=$(($VBUS_IPSOUT >> 3 & 0x07))
VBUS_V_LIMIT=$(echo "scale=2;$VBUS_V_LIMIT*0.10+4.00"|bc)
[ $(($VBUS_IPSOUT & 0x40)) -ne 0 ] && VBUS_V_LIMIT_E="Enabled" \
    || VBUS_V_LIMIT_E="Disabled"
echo "  VBUS voltage limit = "$VBUS_V_LIMIT"V ("$VBUS_V_LIMIT_E")"

VBUS_I_LIMIT=$((VBUS_IPSOUT & 3))
echo -n "  VBUS current limit = "
case $VBUS_I_LIMIT in
  0) echo "900mA";;
  1) echo "500mA";;
  2) echo "100mA";;
  3) echo "~spooky~ unlimited";;
  *) echo "?";;
esac

################################
#read Charge control registers @33h
CHARGE_CTL=$(i2cget -y -f 0 0x34 0x33)

if [ $(($CHARGE_CTL & 0x80)) -ne 0 ] ; then
    echo "Battery charging enabled"

    echo -n "  Charging target voltage = "
    case $((($CHARGE_CTL & 0x60) >> 5)) in
      0) echo "4.10V";;
      1) echo "4.15V";;
      2) echo "4.20V";;
      3) echo "4.36V";;
      *) echo "?";;
    esac
    
    CHARGE_I_LIMIT=$(($CHARGE_CTL & 0x0f))
    CHARGE_I_LIMIT=$(echo "$CHARGE_I_LIMIT*100+300"|bc)
    echo "  Charge current limit = "$CHARGE_I_LIMIT"mA"

    [ $(($CHARGE_CTL & 0x10)) -ne 0 ] && CHARGE_I_TERM="0.15" || CHARGE_I_TERM="0.10"
    CHARGE_I_TERM=$(echo "$CHARGE_I_LIMIT*$CHARGE_I_TERM"|bc)
    echo "  Charge termination current = "$CHARGE_I_TERM"mA"
else
  echo "Battery charging disabled"
fi

###################
#read BATTERY information
if [ $(($POWER_OP_MODE & 0x20)) -ne 0 ] ; then
    echo "Battery present"
    ################################
    #read battery voltage	79h, 78h	0 mV -> 000h,	1.1 mV/bit	FFFh -> 4.5045 V
    BAT_VOLT_MSB=$(i2cget -y -f 0 0x34 0x78)
    BAT_VOLT_LSB=$(i2cget -y -f 0 0x34 0x79)

    BAT_BIN=$(( ($BAT_VOLT_MSB << 4) | ($BAT_VOLT_LSB & 0x0F) ))
    BAT_VOLT=$(echo "$BAT_BIN*1.1"|bc)
    echo "  Battery voltage = "$BAT_VOLT"mV"

    ###################
    #read Battery Discharge Current	7Ch, 7Dh	0 mV -> 000h,	0.5 mA/bit	1FFFh -> 1800 mA
    #13 bits
    BAT_IDISCHG_MSB=$(i2cget -y -f 0 0x34 0x7C)
    BAT_IDISCHG_LSB=$(i2cget -y -f 0 0x34 0x7D)

    BAT_IDISCHG_BIN=$(( ($BAT_IDISCHG_MSB << 5) | ($BAT_IDISCHG_LSB & 0x1F) ))
    BAT_IDISCHG=$(echo "($BAT_IDISCHG_BIN*0.5)"|bc)
    echo "  Battery discharge current = "$BAT_IDISCHG"mA"

    ###################
    #read Battery Charge Current	7Ah, 7Bh	0 mV -> 000h,	0.5 mA/bit	FFFh -> 1800 mA
    #(12 bits)
    BAT_ICHG_MSB=$(i2cget -y -f 0 0x34 0x7A)
    BAT_ICHG_LSB=$(i2cget -y -f 0 0x34 0x7B)

    BAT_ICHG_BIN=$(( ($BAT_ICHG_MSB << 4) | ($BAT_ICHG_LSB & 0x0F) ))
    BAT_ICHG=$(echo "$BAT_ICHG_BIN*0.5"|bc)
    echo "  Battery charge current = "$BAT_ICHG"mA"

    FUEL_GAUGE=$(i2cget -y -f 0 0x34 0x0b9)
    FUEL_GAUGE=$(($FUEL_GAUGE&0x7f))
    echo "  Fuel Gauge="$FUEL_GAUGE"%"
else
    echo "Battery not present"
fi