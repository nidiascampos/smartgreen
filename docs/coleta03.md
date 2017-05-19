# Coleta 03

## Info sobre os modulos
- geral:
  + todos os módulos foram ajustados para reportar um VCC mais acurado
- modulo 00:
  + raspberry zero
  + antena rf24
  + RTC
  + hub usb
  + modem 3g usb
  + modulo wifi
- modulo 01:
  + arduino pro mini 5v 16mhz: SEM regulador de voltagem e SEM led
  + adaptador rf24: COM led
  + antena rf24
  + bateria: 5.44 (reportado 5.26 pelo arduino)
- modulo 02:
  + arduino pro mini 5v 16mhz: SEM regulador de voltagem e SEM led
  + adaptador rf24: SEM led
  + antena rf24
  + bateria: 5.62v (reportado 5.244 pelo arduino)
- modulo 03:
  + arduino nano: COM regulador de voltagem e COM leds
  + adaptador rf24: SEM led
  + antena rf24
  + OBS: apesar do nano ter saída de 3.3v o adaptador rf24 torna a comunicação mais estável
  + bateria: 5.62v (reportado 5.437 pelo arduino)
- modulo 04:
  + arduino pro mini 5v 16mhz: COM regulador de voltagem e COM led
  + 2017-05-18: a placa foi refeita e agora a entrada de energia é pelo RAW e não pelo VCC
  + adaptador rf24: SEM led
  + antena rf24
  + bateria: 5.64v (reportado 5.34 pelo arduino)
- modulo 05:
  + arduino nano: COM regulador de voltagem e COM leds
  + antena rf24 (não precisa de adaptador pois tem saída 3.3v)
  + sensor de chuva COM 2 leds de status 
  + sensor de temperatura à prova d'água
  + bateria (2017-04-27): 6.44v (reportado 5.03v pelo arduino, sendo esta bateria está conectada no RAW, e não VCC, pois estou utilizando o regulador de voltagem)