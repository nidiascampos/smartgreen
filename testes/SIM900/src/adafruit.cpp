#include <Arduino.h>

int8_t answer;
char aux_str[50];
char feed_host[18]="io.adafruit.com";
char feed_key[8]="615157";
char message_content_length[4];
char feed_value[3];
char message_header[170];
char message_header1[18]="POST /api/feeds/";
char message_header2[25]="/data HTTP/1.1\r\nHOST: ";
char message_header3[105]="\r\ncontent-type: application/json\r\nx-aio-key: f38fefdd1fa94e2aaec9fd857b036e19\r\ncontent-length: ";
char message_header4[10]="\r\n\r\n";
char message_content[25];
char message_content1[15]="{\"value\":\"";
char message_content2[5]="\"}";
char message[200];

int sensor_data=4;
// char teste[200]="POST /api/feeds/"+feed_key+"/data HTTP/1.1\r\nHOST: "+feed_host+"\r\ncontent-type: application/json\r\nx-aio-key: f38fefdd1fa94e2aaec9fd857b036e19\r\ncontent-length: 14\r\n\r\n{\"value\":\""+feed_value+"\"}";

void sendATcommand2b(const char* ATcommand);
int8_t sendATcommand2(const char* ATcommand, const char* expected_answer1, const char* expected_answer2, unsigned int timeout);
void sendSensorData(const char* feed_key, int sensor_value);
void powerOn();

void setup(){
    Serial.begin(19200);
    Serial.println("Starting...");
    powerOn();
    // delay(3000);
    // sets the PIN code
    //sendATcommand2("AT+CPIN=1010", "OK", "ERROR", 2000);
    delay(3000);
    Serial.println("Connecting to the network...");
    while( sendATcommand2("AT+CREG?", "+CREG: 0,1", "+CREG: 0,5", 1000)== 0 );
}

void powerOn() {
  // Test to check if shield is awake
  // if it isn't, the first byte will be ignored
  sendATcommand2b("AT");
  sendATcommand2b("AT+CSCLK=0"); // disable sleep mode (avoid losing command bytes)
  sendATcommand2b("AT+CFUN=1"); // set power mode to 1 (full functionality)
  delay(3000);
}

void sendSensorData(const char* feed_key, int sensor_value) {
  message_content[0] = 0;
  message_content_length[0] = 0;
  message_header[0] = 0;
  feed_value[0] = 0;
  message[0] = 0;

  sprintf(feed_value,"%d",sensor_value); // convertendo int para char

  // concatenando chars do conteúdo da mensagem
  strcat(message_content, message_content1);
  strcat(message_content, feed_value);
  strcat(message_content, message_content2);
  sprintf(message_content_length,"%d",strlen(message_content)); // obtendo o tamanho da mensagem (em bytes), convertendo de int para char e armazenando em uma variavel

  // concatenando chars do header da mensagem
  strcat(message_header, message_header1);
  strcat(message_header, feed_key);
  strcat(message_header, message_header2);
  strcat(message_header, feed_host);
  strcat(message_header, message_header3);
  strcat(message_header, message_content_length);
  strcat(message_header, message_header4);

  // concatenando header e conteúdo
  strcat(message, message_header);
  strcat(message, message_content);

  // send message;
  sprintf(aux_str,"AT+CIPSEND=%d", strlen(message));
  if (sendATcommand2(aux_str, ">", "ERROR", 10000) == 1)
  {
      sendATcommand2b(message);
      // sendATcommand2b(sendFeedValue("615157",sensor_data));
  }
}

void loop(){
    ++sensor_data;

    powerOn();

    // Selects Single-connection mode
    if (sendATcommand2("AT+CIPMUX=0", "OK", "ERROR", 1000) == 1)
    {
        // Waits for status IP INITIAL
        while(sendATcommand2("AT+CIPSTATUS", "INITIAL", "", 500)  == 0 );
        delay(5000);

        // Sets the APN, user name and password
        if (sendATcommand2("AT+CSTT=\"timbrasil.br\",\"tim\",\"tim\"", "OK",  "ERROR", 30000) == 1)
        {
            // Waits for status IP START
            while(sendATcommand2("AT+CIPSTATUS", "START", "", 500)  == 0 );
            delay(5000);

            // Brings Up Wireless Connection
            if (sendATcommand2("AT+CIICR", "OK", "ERROR", 30000) == 1)
            {
                // Waits for status IP GPRSACT
                while(sendATcommand2("AT+CIPSTATUS", "GPRSACT", "", 500)  == 0 );
                delay(5000);

                // Gets Local IP Address
                if (sendATcommand2("AT+CIFSR", ".", "ERROR", 10000) == 1)
                {
                    // Waits for status IP STATUS
                    while(sendATcommand2("AT+CIPSTATUS", "IP STATUS", "", 500)  == 0 );
                    delay(5000);
                    Serial.println("Openning TCP");

                    // Opens a TCP socket
                    if (sendATcommand2("AT+CIPSTART=\"TCP\",\"io.adafruit.com\",\"80\"",
                            "CONNECT OK", "CONNECT FAIL", 30000) == 1)
                    {
                        Serial.println("Connected");

                        // WM_01_15
                        sendSensorData("615157",sensor_data);
                        delay(10000);

                        // WM_01_40
                        sendSensorData("615158",sensor_data+3);
                        delay(10000);

                        // WM_01_75
                        sendSensorData("615159",sensor_data+7);
                    }
                    else
                    {
                        Serial.println("Error openning the connection");
                    }
                }
                else
                {
                    Serial.println("Error getting the IP address");
                }
            }
            else
            {
                Serial.println("Error bring up wireless connection");
            }
        }
        else
        {
            Serial.println("Error setting the APN");
        }
    }
    else
    {
        Serial.println("Error setting the single connection");
    }

    sendATcommand2b("AT+CIPSHUT"); // closing data connection
    sendATcommand2b("AT+CFUN=0"); // set power mode to 0 (minimium functionality)
    sendATcommand2b("AT+CSCLK=2"); // set sleep mode 2
    delay(60000);
}

void sendATcommand2b(const char* ATcommand){
    // versão modificada da funćão sendATcommand2, não armazena a resposta e nem define timeout
    delay(100);

    while( Serial.available() > 0) Serial.read();    // Clean the input buffer

    Serial.println(ATcommand);    // Send the AT command
}


int8_t sendATcommand2(const char* ATcommand, const char* expected_answer1,
        const char* expected_answer2, unsigned int timeout){

    uint8_t x=0,  answer=0;
    char response[100];
    unsigned long previous;

    memset(response,0, 100);    // Initialize the string

    delay(100);

    while( Serial.available() > 0) Serial.read();    // Clean the input buffer

    Serial.println(ATcommand);    // Send the AT command

    x = 0;
    previous = millis();

    // this loop waits for the answer
    do{
        // if there are data in the UART input buffer, reads it and checks for the asnwer
        if(Serial.available() != 0){
            response[x] = Serial.read();
            x++;
            // check if the desired answer 1  is in the response of the module
            if (strstr(response, expected_answer1) != NULL)
            {
                answer = 1;
            }
            // check if the desired answer 2 is in the response of the module
            else if (strstr(response, expected_answer2) != NULL)
            {
                answer = 2;
            }
        }
    }
    // Waits for the asnwer with time out
    while((answer == 0) && ((millis() - previous) < timeout));

    return answer;
}
