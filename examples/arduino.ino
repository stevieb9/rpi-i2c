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

  int16_t data;
  
  while(Wire.available()){
    if (num_bytes > 1){
      // throw away register byte if we received one
      int8_t reg = Wire.read();
      Serial.print("register addr: ");
      Serial.println(reg);
    }
    
    if (num_bytes > 2){
      data = Wire.read();
      data += Wire.read() << 8;
    }
    else {
      data = Wire.read();
    }
    
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
