#include <Arduino.h>

int8_t answer;
// int onModulePin= 2;
char aux_str[50];
char ip_data[40]="Test string from GPRS shield\r\n";
char teste[200]="POST /api/feeds/611544/data HTTP/1.1\r\nHOST: io.adafruit.com\r\ncontent-type: application/json\r\nx-aio-key: f38fefdd1fa94e2aaec9fd857b036e19\r\ncontent-length: 14\r\n\r\n{\"value\":\"26\"}";

int8_t sendATcommand2b(char* ATcommand);
int8_t sendATcommand2(char* ATcommand, char* expected_answer1,char* expected_answer2, unsigned int timeout);

void setup(){
    // pinMode(onModulePin, OUTPUT);
    Serial.begin(19200);
    Serial.println("Starting...");
    // power_on();
    delay(3000);
    // sets the PIN code
    sendATcommand2("AT+CPIN=1010", "OK", "ERROR", 2000);
    delay(3000);
    Serial.println("Connecting to the network...");
    while( sendATcommand2("AT+CREG?", "+CREG: 0,1", "+CREG: 0,5", 1000)== 0 );
    // while( sendATcommand2("AT+CGATT?", "1", "0", 1000)== 1 );
}

void loop(){
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

                        // Sends some data to the TCP socket
                        sprintf(aux_str,"AT+CIPSEND=%d", strlen(teste));
                        if (sendATcommand2(aux_str, ">", "ERROR", 10000) == 1)
                        {
                            sendATcommand2b(teste);
                        }
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

    sendATcommand2b("AT+CIPSHUT");
    delay(60000);
}

int8_t sendATcommand2b(char* ATcommand){
    // versão modificada da funćão sendATcommand2, não armazena a resposta e nem define timeout
    delay(100);

    while( Serial.available() > 0) Serial.read();    // Clean the input buffer

    Serial.println(ATcommand);    // Send the AT command
}


int8_t sendATcommand2(char* ATcommand, char* expected_answer1,
        char* expected_answer2, unsigned int timeout){

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
