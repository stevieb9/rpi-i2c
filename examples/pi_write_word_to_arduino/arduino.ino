#include <Wire.h>

#define SLAVE_ADDR 0x04
#define DAC_0 A0
#define DAC_1 A1

void send_data (){
  Wire.write(analogRead(DAC_0));
}

void receive_data (int num_bytes){
  Serial.print("bytes in: ");
  Serial.println(num_bytes);
  
  while(Wire.available()){
    Wire.read(); // throw away register byte
    
    int16_t data = Wire.read(); // low byte
    data += Wire.read() << 8;   // high byte
    
    Serial.print("data: ");
    Serial.println(data);
  }
  Serial.println("\n");
}

void setup() {
  Serial.begin(9600);
  Wire.begin(SLAVE_ADDR);
  Wire.onReceive(receive_data);
  Wire.onRequest(send_data);
}

void loop() {
}
