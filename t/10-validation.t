use strict;
use warnings;

use Test::More;
use IO::File;
use RPi::I2C;

# HW-free unit coverage. The addr validation croaks before the bus is opened;
# _set_reg is a pure sub; and read_bytes/write_word run against a faked object
# (a blessed /dev/null handle) with the XS read/write stubbed - so no I2C bus
# or device is touched. read_bytes (F7) and write_word (F8) carry known
# contract bugs; these tests PIN the current behaviour (the fixes are a
# coordinated API-contract change, deferred to B18 in the test-coverage plan).

# --- new(): addr must be an integer (croaks before the device is opened) ---

for my $bad (undef, 'xx', '0x78') {
    my $shown = defined $bad ? "'$bad'" : 'undef';
    eval { RPi::I2C->new($bad) };
    like $@, qr/requires the \$addr param/, "new($shown) croaks before opening the bus";
}
# Note: "0x78" is rejected because the check is /^\d+$/ - hex must be passed as
# a numeric literal (0x78), not a string.

# --- _set_reg(): an undef register defaults to DEFAULT_REGISTER (0x00) ---

is RPi::I2C::_set_reg(undef), 0x00, "_set_reg(undef) defaults to 0x00";
is RPi::I2C::_set_reg(0x15),  0x15, "_set_reg(0x15) passes through";

# --- faked object: no bus; XS reads/writes stubbed ---

{
    no warnings 'redefine';
    # Echo the register address so we can see which byte read_bytes returns.
    local *RPi::I2C::_readByteData = sub { return $_[1]; };
    my @write_args;
    local *RPi::I2C::_writeWordData = sub { @write_args = @_; return 1; };

    my $obj = bless IO::File->new('/dev/null'), 'RPi::I2C';

    # F7: read_bytes() OVERWRITES $retval each pass ($retval = (0<<8)|byte)
    # instead of accumulating, so it returns a single scalar - the byte at the
    # BASE register - not the documented array of N bytes. PINNED (bug -> B18).
    is $obj->read_bytes(4, 0x10), 0x10,
        "read_bytes(4, 0x10) returns only the base-register byte, not 4 bytes (F7, pinned)";

    # F8: write_word($reg, $value) treats its FIRST positional as the register
    # and SECOND as the value - inconsistent with write_byte($value, $reg) and
    # with its own POD (write_word($data, [$reg])). PINNED (bug -> B18).
    $obj->write_word(0x10, 0xABCD);
    is_deeply [@write_args[1, 2]], [0x10, 0xABCD],
        "write_word(0x10, 0xABCD) sends (reg=0x10, value=0xABCD) - first arg is the register (F8, pinned)";
}

done_testing();
