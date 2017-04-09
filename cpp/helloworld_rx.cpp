/*
 Update 2014 - TMRh20
 */

/**
 * Simplest possible example of using RF24Network,
 *
 * RECEIVER NODE
 * Listens for messages from the transmitter and prints them out.
 */

#include <RF24/RF24.h>
#include <RF24Network/RF24Network.h>
#include <iostream>
#include <fstream>
#include <ctime>
#include <stdio.h>
#include <time.h>
#include <string>

using namespace std;

/**
 * g++ -L/usr/lib main.cc -I/usr/include -o main -lrrd
 **/
//using namespace std;

// CE Pin, CSN Pin, SPI Speed

// Setup for GPIO 22 CE and CE1 CSN with SPI Speed @ 8Mhz
RF24 radio(RPI_V2_GPIO_P1_15, BCM2835_SPI_CS0, BCM2835_SPI_SPEED_8MHZ);  

RF24Network network(radio);

// Address of our node in Octal format
const uint16_t this_node = 00;

struct payload_t {                  // Structure of our payload
  unsigned long wm15;
  unsigned long wm45;
  unsigned long wm75;
  unsigned long counter;
};

int main(int argc, char** argv)
{
	// Start Radio
	radio.begin();
	delay(5);

	// Format: channel, node address
	network.begin(90, this_node);

	// Print Radio Config
	radio.printDetails();

	while(1)
	{

		 network.update();
  		 while ( network.available() ) {     // Is there anything ready for us?
		 	RF24NetworkHeader header;    // If so, grab it and print it out
   			payload_t payload;
  			network.read(header,&payload,sizeof(payload));

			// Time
			time_t now = time(0);
			char* dt = ctime(&now);
			printf(dt);

			// Output
			//printf("Id | Node | WM15 | WM45 | WM75");
			//printf("Payload: ");
			//printf("Received payload # %lu | ",payload.counter);
			//printf("%u | ",header.id);
			//printf("%u | ",header.from_node);
			//printf("%lu | ",payload.wm15);
			//printf("%lu | ",payload.wm45);
			//printf("%lu \n",payload.wm75);
			printf("Payload: %u | %lu | %lu | %lu \n",header.from_node,payload.wm15,payload.wm45,payload.wm75);
			//string teste;
			//char buffer[100];
			//teste = sprintf(buffer,"%u | %lu | %lu | %lu \n",header.from_node,payload.wm15,payload.wm45,payload.wm75);
			//print(teste);

			//ofstream myfile;
			//myfile.open("output.txt");
			//myfile << teste;
			//myfile << "blabla";
			//myfile.close();

			FILE * pFile;
			pFile = fopen("output.txt", "a"); // a = append, w = (over)write
			fprintf(pFile,dt);
			fprintf(pFile,"Payload: %u | %lu | %lu | %lu \n",header.from_node,payload.wm15,payload.wm45,payload.wm75);
			fclose(pFile);
                 }
		 delay(2000);
	 }

	return 0;
}

