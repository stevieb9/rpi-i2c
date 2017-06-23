use warnings;
use strict;

# write block (array) to Arduino

use RPi::I2C;

my $arduino_addr = 0x04;

my $arduino = RPi::I2C->new($arduino_addr);

$arduino->write_block([5, 10, 15, 20], 0x00);

sub delay {
    die "delay() needs a number\n" if ! @_;
    return select(undef, undef, undef, shift);
}
