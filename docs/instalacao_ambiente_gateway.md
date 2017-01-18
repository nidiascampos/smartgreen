# Instruções de configuração do nó gateway (sink)

## Configurar locales e fuso horario
- instalar pacotes necessários
  ```
  sudo apt install locales
  ```

- configurar locales
  ```
  sudo dpkg-reconfigure locales
  sudo locale-gen
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
  sudo apt-get update
  sudo apt-get install mosquitto mosquitto-clients
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
  sudo apt install pppconfig
  sudo cp smartgreen/conf/pppconfig/chatscripts/claro /etc/chatscripts/claro
  sudo cp smartgreen/conf/pppconfig/claro /etc/ppp/peers/claro
  ```

- testar conexão
  ```
  sudo pon claro
  tail /var/log/messages
  ```

## MongoDB
- instalar mongo
  ```
  sudo apt install mongodb
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