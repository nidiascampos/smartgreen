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
