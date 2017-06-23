use warnings;
use strict;

# writes an 8-bit byte to the Arduino

# LSB is read first, then the MSB

use RPi::I2C;

my $arduino_addr = 0x04;

my $arduino = RPi::I2C->new($arduino_addr);

my $x = $arduino->write(254, 0x00);

sub delay {
    die "delay() needs a number\n" if ! @_;
    return select(undef, undef, undef, shift);
}
