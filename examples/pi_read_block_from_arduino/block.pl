use warnings;
use strict;

# read block from Arduino

use RPi::I2C;

my $arduino_addr = 0x04;

my $arduino = RPi::I2C->new($arduino_addr);

for (0..10){
    my @a = $arduino->read_block(0x05, 2);

    my $num = ($a[0] << 8) | $a[1];
    
    print "$num\n";

    # delay(0.5);
}

sub delay {
    die "delay() needs a number\n" if ! @_;
    return select(undef, undef, undef, shift);
}
