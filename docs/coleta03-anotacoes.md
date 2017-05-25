# visita 2017-04-27
## status das baterias
8h55 -> modulo 1: 5.00
8h44 -> modulo 2: 5.12
8h52 -> modulo 3: 4.62
??? modulo 4 ???

## modulo 4
- parou de transmitir em 2017-04-26 20:22:39
- voltou a transmitir em 2017-04-27 09:22:50
- ultimos dados do modulo 4 antes de parar de transmitir:
  ```
  2017-04-26 19:23:33,297 Payload from module ID 04: 486 -835 1194 -392 585 152 4.9379696846
  2017-04-26 19:53:06,239 Payload from module ID 04: 492 -842 1195 -386 583 155 4.9379696846
  2017-04-26 20:22:39,172 Payload from module ID 04: 497 -850 1187 -379 581 144 4.91612005234
  ```

## ajustes gerais
- modulo 4 voltou a transmitir após ser reiniciado
- fita adesiva do modulo 3 foi reforçada (parece que algum animal mexeu, provavelmente um passaro pois havia fezes)
- modulo 5 removido para ser modificado pois está transmitindo a cada 30 segundos, e nao 30 minutos
- fio de energia do sensor de temperatura estava praticamente partido (talvez algum animal tenha puxado)
- modulo 5 teve a placa substituida (arduino nano em protoboard por arduino pro mini em placa soldada)
- novos dados de energia do modulo 5: 5.03 / 6.44 (ligado no RAW, e não VCC, pois tem regulador de voltagem)
- nao pude reinstalar o modulo 5 devido à problemas na antena, levando de volta à Fortaleza para reparo

# visita 2017-05-04
- uptime raspberry: 09:20:14 up 5 days, 19:19,  1 user,  load average: 0.05, 0.03, 0.00
- modulos aparentemente pararam de transmitir dia 01 de Maio
- ultimas mensagens:
  + modulo 01: 
    > 2017-05-01 05:38:24,121 Payload from module ID 01: 1041 554 370 -153 560 199 4.67007017136
  + modulo 02: 
    > 2017-04-30 16:06:14,095 Payload from module ID 02: 797 252 764 -58 3020 -573 4.8639421463
  + modulo 03:
    > 2017-04-30 17:11:51,107 Payload from module ID 03: 3307 752 1169 200 3444 -665 3.16706132889
  + modulo 04: 
    > 2017-05-01 05:11:07,912 Payload from module ID 04: 904 -300 1001 -326 1228 291 3.0028192997
    > começou a mandar pacotes no tamanho errado
    > 2017-05-01 05:40:29,635 !!! Wrong payload size from module ID 04: 26 bytes
- modulos foram retirados e examinados individualmente
- modulo 5 reinstalado

## modulo 1
- o botão de reset não fez o modulo voltar a se comunicar
- ao retirar e recolocar as baterias ele voltou a funcionar
- baterias aparentemente ok, reportando 4.35v pelo multimetro e 4.245v pelo arduino
- baterias trocadas, agora reportando 5.12v pelo multimetro e 5.0036v pelo arduino

## modulo 2
- baterias estouradas mas modulo ainda funciona ok
- baterias trocadas agora reportando 5.29v pelo multimetro e 4.99v pelo arduino

## modulo 3
- baterias aparentemente ok, mas reportando 0.56v pelo multimetro
- duas descarregaram completamente, ao ponto de inverter a voltagem
- baterias trocadas, agora reportando 5.6v pelo multimetro e 5.46v pelo arduino

## modulo 4
- baterias aparentemente ok, mas reportando 0.32v pelo multimetro
- duas descarregaram completamente, ao ponto de inverter a voltagem
- baterias trocadas, agora reportando 5.45v pelo multimetro, mas arduino nao responde
- arduino nao responde nem por usb
- retirado para manutenção

## modulo 5
- baterias reportando 6.26v pelo multimetro e 5.02v pelo arduino

# visita 2017-05-09
- todos os modulos (01, 02, 03, 05) aparentemente ok
- ultimas mensagens:
  + modulo 01: 
    > 2017-05-09 09:27:07,096 Payload from module ID 01: 2832 -742 553 250 580 203 4.51942300797
  + modulo 02: 
    > 2017-05-09 09:54:08,068 Payload from module ID 02: 793 -217 630 4 6528 -600 4.94853258133
  + modulo 03:
    > 2017-05-09 09:44:31,825 Payload from module ID 03: 2013 489 3369 -428 3403 694 4.57464456558
  + modulo 05: 
    > 2017-05-09 09:30:31,079 Payload from module ID 05: 218 True 26.75 4.67007017136
- modulo 04 não foi recolocado (arduino realmente queimou e preciso refazer o módulo)
- adaptador wifi instalado no raspberry zero
- repetidor wifi instalado na administração para fazer o sinal chegar ao raspberry
- apesar do sinal ser fraco/instável, raspberry tem conseguido transmitir os dados por wifi para o thingspeak
- OBS: melhorar a robustez do código de publicação de dados em caso de queda de conexão durante a transmissão, e para fazer novas tentativas (o código antigo de tentativas foi feito para o modem 3g)

# visita 2017-05-18
- status raspberry pi:
  > uptime:  09:16:18 up 8 days, 23:19,  1 user,  load average: 1.02, 1.01, 1.00
- todos os modulos aparentemente descarregaram
- ultimas mensagens:
  + modulo 01:
    > 2017-05-11 05:31:56,169 Payload from module ID 01: 1352 -544 525 235 641 200 3.49164104462
  + modulo 02:
    > 2017-05-15 23:07:37,650 Payload from module ID 02: 1490 -239 560 127 5897 -457 3.62472105026
  + modulo 03:
    > 2017-05-10 19:24:47,382 Payload from module ID 03: 1238 340 739 -216 3165 734 3.79213929176
  + modulo 05:
    > 2017-05-15 19:20:35,135 Payload from module ID 05: 1023 False -127.0 2.74038338661
- dados do mongodb foram copiados
- pilhas dos modulos 01, 02, 03 e 05 foram substituidas
- modulo 02 não funcionou (case das pilhas envergou e não faz contato corretamente, pilhas foram retiradas)
- modulo 03 funcionou
- modulo 04 foi reinstalado (nova placa)

# visita 2017-05-23
- status raspberry pi:
  > uptime: 09:28:13 up 4 days, 23:44,  1 user,  load average: 1.05, 1.04, 1.00
- ultimas mensagens:
  + modulo 01:
    > 2017-05-18 12:46:18,241 Payload from module ID 01: 2764 -532 604 185 1722 470 5.23746156693
  + modulo 02:
    > desligado desde a ultima visita
  + modulo 03:
    > 2017-05-23 09:03:53,872 Payload from module ID 03: 558 181 482 -164 3018 765 4.64842891693
  + modulo 04:
    > 2017-05-23 09:07:31,064 Payload from module ID 04: 546 -1067 406079 821559 -1 -13 5.0743303299
  + modulo 05:
    > 2017-05-23 09:12:21,258 Payload from module ID 05: 1023 False 27.5625 4.74922370911
- aparentemente alguma das pilhas do modulo 01 pararam de funcionar após a visita do dia 18, apesar de terem sido substituidas e acusar ~5.24v na troca
- pilhas do modulo 01 foram substituidas (5,51v)
- case de pilhas do modulo 02 foi substituido (5,8v)
- modulo 2 ainda não funciona
- retirei o arduino do modulo 2 e conectei ao notebook e ele aparentemente funcionou ok, não sei qual o problema
- recoloquei o arduino do modulo 2 e o deixei ligado, esperando que ele volte a se comunicar
- pilhas do modulo 03 foram substituidas (5,85v)
- pilhas do modulo 04 foram substituidas (6,46v)
- pilhas do modulo 05 foram substituidas (6,46v)