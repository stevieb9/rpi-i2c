#include <Wire.h>

#define SLAVE_ADDR 0x04
#define DAC_0 A0

void send_data (){
    Wire.write(analogRead(DAC_0));
}

void receive_data (int num_bytes){
}

void setup() {
    Wire.begin(SLAVE_ADDR);
    Wire.onReceive(receive_data);
    Wire.onRequest(send_data);
}

void loop() {
}
