usb_modeswitch -I -c /etc/usb_modeswitch.d/2001:a80b -v 2001 -p a80b
sleep 5
modprobe usbserial vendor=0x2001 product=0x7d00
