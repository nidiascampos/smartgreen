// ENVIO DE SMS POR COMANDOS SERIAIS DO ARDUINO PARA SHIELD GSM SIM900
// baseado no código de: http://www.fut-electronics.com/wp-content/plugins/fe_downloads/Uploads/GSM-shield-datasheet-Arduino-tutorial.pdf
// lembrar de conectar pinos 0 (RX) e 1 (TX) da shield com o arduino
// e também de setar a shield GSM no modo Xduino (hardware serial)

#include <Arduino.h>

void setup() {
    Serial.begin(19200); // abrir conexao serial
    Serial.print("\r");
    delay(1000); // aguardar 1 seg para o modem enviar o OK
    Serial.print("AT+CMGF=1\r"); // definir que o conteudo do SMS é texto
    delay(1000);

    Serial.print("AT+CMGS=\"+5585981901528\"\r"); // numero que irá receber o SMS
    delay(1000);
    Serial.print("arduino gsm test\r"); // conteúdo do SMS
    delay(1000);
    Serial.write(26); // hex 1A (equivalente a CTRL+Z) para concluir a linha
}

void loop() {
  // nenhum código aqui pois só queremos enviar 1 SMS, e não fazer um loop de envio
}
