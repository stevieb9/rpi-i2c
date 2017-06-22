use warnings;
use strict;

# does a single byte basic read() from an Arduino
# and prints out whatever is returned

use RPi::I2C;

my $arduino_addr = 0x04;

my $arduino = RPi::I2C->new($arduino_addr);

for (0..512){
    my $d = $arduino->read;
    print "$d\n";
}
