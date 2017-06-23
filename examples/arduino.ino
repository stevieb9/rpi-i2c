#include <Wire.h>

#define SLAVE_ADDR 0x04
#define DAC_0 A0
#define DAC_1 A1

#define READ        0
#define READ_BYTE   5
#define READ_BLOCK  10

#define WRITE       25
#define WRITE_BYTE  30
#define WRITE_BLOCK 35

#define READ_A0     80
#define READ_A1     81

int8_t reg;

void send_data (){

    switch (reg) {

        case READ: {
            Serial.println("read()");
            Wire.write(reg);
            break;
        }
        case READ_BYTE: {
            Serial.println("read_byte()");
            Wire.write(reg);
            break;
        }
        case READ_BLOCK: {
            Serial.println("read_block()");
            int value = 1023;
            uint8_t buf[2];

            // reverse endian so we're big on the way out, and separate the
            // 16-bit word

            buf[1] = value & 0xFF;
            buf[0] = (value & 0xFF00) >> 8;

            Wire.write(buf, 2);
            break;
        }
        case READ_A0: {
            Serial.println("Analog 0");
            read_analog(A0);
            break;
        }
        case READ_A1: {
            Serial.println("Analog 0");
            read_analog(A0);
            break;
        }
    }
}

int read_analog (int pin){
    int val = analogRead(pin);
    Serial.println(pin);

    uint8_t buf[2];

    // reverse endian so we're big endian going out

    buf[1] = val & 0xFF;
    buf[0] = (val & 0xFF00) >> 8;

    Serial.print("0: ");
    Serial.println(buf[0]);
    Serial.print("1: ");
    Serial.println(buf[1]);

    Serial.println(val);

    Wire.write(buf, 2);
}

void receive_data (int num_bytes){

    int16_t data = 0;

    while(Wire.available()){
        // save the register value for use later
        reg = Wire.read();

        if (reg == WRITE){
            Serial.println("write()");
            data = reg;
        }
        if (reg == WRITE_BYTE){
            Serial.println("write_byte()");
            data = Wire.read();
        }
        if (reg == WRITE_BLOCK){
            byte buf[4];

            for (byte i=0; i<4; i++){
                buf[i] = Wire.read();
                data += buf[i];
                Serial.print(i);
                Serial.print(": ");
                Serial.println(buf[i]);
            }
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
    delay(1000);
}
