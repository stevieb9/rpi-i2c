use warnings;
use strict;

# read block from Arduino

# 1023

use RPi::I2C;

my $arduino_addr = 0x04;

my $arduino = RPi::I2C->new($arduino_addr);

my @a = $arduino->read_block(2, 0x0A);

my $num = ($a[0] << 8) | $a[1];

print "$num\n";

sub delay {
    die "delay() needs a number\n" if ! @_;
    return select(undef, undef, undef, shift);
}
