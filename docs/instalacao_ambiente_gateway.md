# Instruções de configuração do nó gateway (sink)

## Pre-requisitos
- instalar pacotes
  ```
  sudo apt install build-essential libncurses5-dev git locales pppconfig mongodb python3 python3-dev flex bison modemmanager
  ```

## Configurar locales e fuso horario

- configurar locales
  ```
  sudo dpkg-reconfigure locales
  sudo locale-gen
  echo 'export LC_ALL="en_US.UTF-8"' >> ~/.bashrc
  ```

- configurar fuso horario
  ```
  sudo dpkg-reconfigure tzdata
  ```

- reiniciar

## Broker MQTT Mosquitto
- adicionar repositório debian do mosquitto
  ```
  wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
  sudo apt-key add mosquitto-repo.gpg.key
  cd /etc/apt/sources.list.d/
  sudo wget http://repo.mosquitto.org/debian/mosquitto-jessie.list
  sudo apt update
  sudo apt install mosquitto mosquitto-clients
  ```

- adicionar mosquitto à lista de serviços iniciadas no boot
  ```
  sudo systemctl enable mosquitto
  ```

- caso o serviço não funcione, desabilitar o arquivo padrão e utilizar o disponível em `conf/systemd/mosquitto.service`
  ```
  sudo systemctl disable mosquitto
  # remover o mosquitto do init.d
  sudo update-rc.d mosquitto remove
  # copia o novo arquivo de inicialização
  sudo cp smartgreen/conf/systemd/mosquitto.service /etc/systemd/system
  # recarregar os scripts de inicialização
  sudo systemctl daemon-reload 
  # iniciar manualmente
  sudo systemctl start mosquitto 
  # verificar se inicializou corretamente
  sudo systemctl status mosquitto 
  # iniciar no boot
  sudo systemctl enable mosquitto 
  ```

## Modem USB
- verificar se o modem USB foi identificado corretamente:
  ```
  dmesg | grep modem
  lsusb | grep D-Link
  ```
  - caso o id seja *2001:a80b* será necessário usar o script de modeswitch, disponível em `conf/ativar_modemusb.sh`
  - caso o id seja *2001:7d00* está tudo ok

- verificar se as portas ttyUSB0 e ttyUSB1 estão disponíveis
  ```
  ls /dev/ttyUSB*
  ```

- instalar o *wvdial* ou *pppconfig*
  ```
  sudo cp smartgreen/conf/pppconfig/chatscripts/claro /etc/chatscripts/claro
  sudo cp smartgreen/conf/pppconfig/claro /etc/ppp/peers/claro
  ```

- adicionar usuario ao grupo necessário para ter permissão de iniciar/encerrar conexão
  ```
  sudo adduser pi dip
  ```

- testar conexão
  ```
  pon claro
  tail /var/log/messages
  poff
  ```

## MongoDB
- criar diretorio de dados do mongo
  ``` 
  sudo mkdir -p /data/db
  ```

## Python (versão 3.x)

### Ambiente Virtual
- ativar ambiente virtual (venv)
  ```
  source smartgreen/python/bin/activate
  ```

- caso o ambiente virtual não exista, criar um
  ```
  # o python do debian normalmente vem sem o pip (acho que é um pacote separado)
  python3 -m venv --without-pip smartgreen/python
  # instalar pip, setuptools e wheel
  curl https://bootstrap.pypa.io/get-pip.py | python
  ```

### Pacotes
*lembrar de ativar o ambiente virtual primeiro*

- instalar utilizando arquivo `requeriments.txt`: `pip install -r requeriments.txt`

- instalar manualmente:
  + Paho: `pip install paho-mqtt`
  + Mongo: `pip install pymongo`
  + w1thermsensor: `pip install w1thermsensor`
  + pppd: `pip install python-pppd`

## Extra
- para evitar mensagem 'rsyslog action 17 suspended' no log do sistema, remover ou comentar as seguintes linhas do arquivo `/etc/rsyslog.conf` (normalmente fica no final do arquivo):
  ```
  daemon.*;mail.*;\
      news.err;\
      *.=debug;*.=info;\
      *.=notice;*.=warn   |/dev/xconsole
  ```


# Pi Zero

## Desabilitar LED de status
Fonte: https://www.jeffgeerling.com/blogs/jeff-geerling/controlling-pwr-act-leds-raspberry-pi

The Pi Zero's values are opposite to the other Pi models, and it only has one LED, led0 (labeled 'ACT' on the board). The LED defaults to on (brightness 0), and turns off (brightness 1) to indicate disk activity.

If you want to turn off the LED on the Pi Zero completely, run the following two commands:
```
# Set the Pi Zero ACT LED trigger to 'none'.
echo none | sudo tee /sys/class/leds/led0/trigger

# Turn off the Pi Zero ACT LED.
echo 1 | sudo tee /sys/class/leds/led0/brightness
```

To make these settings permanent, add the following lines to your Pi's /boot/config.txt file and reboot:
```
# Disable the ACT LED on the Pi Zero.
dtparam=act_led_trigger=none
dtparam=act_led_activelow=on
```

## Desabilitar HDMI
Fonte:

If you're running a headless Raspberry Pi, there's no need to power the display circuitry, and you can save a little power by running `/usr/bin/tvservice -o` (`-p` to re-enable). Add the line to `/etc/rc.local` to disable HDMI on boot.

# CHIP.IO

## Sensor de temperatura
Fonte: https://bbs.nextthing.co/t/keenly-wanting-onewire-support/1737/17?u=andreibosco

The right pin for onewire is PD2 (labelled on the socket LCD-D2).

```
# cat /sys/kernel/debug/pinctrl/1c20800.pinctrl/pinmux-pins | grep onewire
pin 98 (PD2): onewire 1c20800.pinctrl:98 function gpio_in group PD2
```

I have connected a ds18b20 to +3,3v, LCD-D2 and ground, a 4.7K resistor between +3.3v and LCD-D2 and it works:
```
$ sudo modprobe w1_therm 
$ ls /sys/bus/w1/devices/
28-031650decbff  w1_bus_master1
$ cat /sys/bus/w1/devices/28-031650decbff/w1_slave 
30 00 4b 46 ff ff 0f 10 b8 : crc=b8 YES
30 00 4b 46 ff ff 0f 10 b8 t=23812
```

## Sensor chuva
Fonte:
- https://github.com/xtacocorex/CHIP_IO
- https://www.raspberrypi.org/forums/viewtopic.php?f=37&t=75213

- instalar biblioteca DTC
  ```
  git clone https://github.com/atenart/dtc.git
  cd dtc
  make
  sudo  make install PREFIX=/usr
  ```

- instalar biblioteca CHIP_IO. **Obs:** ela já deve estar instalada no ambiente virtual do projeto smartgreen. Seguir os passos abaixo somente se realmente necessário.
  ```
  cd ..
  git clone git://github.com/xtacocorex/CHIP_IO.git
  cd CHIP_IO
  sudo python3 setup.py install
  ```

## RF24 libs
Fonte: https://tmrh20.github.io/RF24/Linux.html

- download do script de instalação e executa-lo
  ```
  wget http://tmrh20.github.io/RF24Installer/RPi/install.sh
  chmod +x install.sh
  ./install.sh
  ```

- para funcionar com o C.H.I.P. é necessário modificar o arquivo *spi.cpp*
  ```
  cd rf24libs/RF24
  make clean
  sudo rm Makefile.inc
  sudo chown chip:chip utility/includes.h
  sed -i 's/spidev0.0/spidev32766.0/g' utility/SPIDEV/spi.cpp # esse comando substitui o texto spidev0.0 por spidev32766.0 no arquivo spi.cpp
  ./configure
  make
  sudo make install
  ```

## Desativar serviços
- avahi-daemon, wpa_supplicant, ssh, supervisor, NetworkManager, bluetooth

## Desabilitar bluetooth
Fonte: https://bbs.nextthing.co/t/disable-c-h-i-p-default-uart-hci-bluetooth/12512

```
sudo systemctl disable bt_rtk_hciattach@ttyS1
sudo systemctl mask bt_rtk_hciattach@ttyS1
```

## Wifi

### Desconectar

- Para desconectar:
  ```
  sudo nmcli dev disconnect wlan0
  ```

- Para esquecer uma rede:
  ```
  nmcli c # obter o nome da rede, ex. NTC 2461
  sudo nmcli connection delete id "NTC 2461"
  ```

## RTC
Fonte: https://bbs.nextthing.co/t/wanted-real-time-clock-setup-instructions/1934/9

```
sudo cp smartgreen/conf/scripts/rtc.sh /etc/init.d
sudo update-rc.d rtc.sh defaults
sudo systemctl disable fake-hwclock.service
sudo systemctl mask fake-hwclock.service
```