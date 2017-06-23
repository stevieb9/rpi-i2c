use warnings;
use strict;
use feature 'say';

use RPi::I2C;

my $uno_addr = 0x04;

my $uno = RPi::I2C->new($uno_addr);

__END__

{ # read()
    print "read()\n";
    print $uno->read . "\n";
}

{ # read_byte()
    print "read_byte()\n";
    print $uno->read_byte(0x05) . "\n";
}


{ # read_block()
    print "read_block()\n";
    say for $uno->read_block(0x00, 2);
}

{ # write()

    print "write()\n";
    $uno->write(67);
}

{ # write_byte()

    print "write_byte()\n";
    $uno->write_byte(0x01, 67);
}


sub delay {
    die "delay() needs a number\n" if ! @_;
    return select(undef, undef, undef, shift);
}
