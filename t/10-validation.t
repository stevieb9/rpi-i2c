use strict;
use warnings;

use Test::More;
use IO::File;
use RPi::I2C;

# HW-free unit coverage. The addr validation croaks before the bus is opened;
# new()'s error paths are exercised with an unopenable path and /dev/null;
# _set_reg is a pure sub; and read_bytes/write_word run against a faked object
# (a blessed /dev/null handle) with the XS read/write stubbed - so no I2C bus
# or device is touched. The read_bytes/write_word/process contracts were
# fixed to match their POD in 3.1803 (test-coverage-gaps B18, executed as
# rpi-i2c-fixes V8); these tests assert the FIXED behaviour.

# --- new(): addr must be an integer (croaks before the device is opened) ---

for my $bad (undef, 'xx', '0x78') {
    my $shown = defined $bad ? "'$bad'" : 'undef';
    eval { RPi::I2C->new($bad) };
    like $@, qr/requires the \$addr param/, "new($shown) croaks before opening the bus";
}
# Note: "0x78" is rejected because the check is /^\d+$/ - hex must be passed as
# a numeric literal (0x78), not a string.

# --- new(): addr must be within the 7-bit I2C range (0x00-0x7F) ---

{
    eval { RPi::I2C->new(0x80) };
    like $@, qr/out of range/, "new(0x80) croaks - beyond the 7-bit address range";

    eval { RPi::I2C->new(1024) };
    like $@, qr/out of range/, "new(1024) croaks - way beyond the 7-bit range";

    # Address 0x00 (the I2C general call) MUST remain legal:
    # RPi::PWM::PCA9685->reset() does RPi::I2C->new(0, ...) for SWRST
    local $ENV{I2C_TESTING} = 1;
    my $gc = RPi::I2C->new(0, '/dev/null');
    isa_ok $gc, 'RPi::I2C', 'new(0, /dev/null) under I2C_TESTING (general call)';

    my $top = RPi::I2C->new(0x7F, '/dev/null');
    isa_ok $top, 'RPi::I2C', 'new(0x7F, /dev/null) under I2C_TESTING (top of range)';
}

# --- new(): unopenable device path croaks with the path + errno ---

{
    my $bad_dev = '/nonexistent/i2c-device';
    eval { RPi::I2C->new(0x20, $bad_dev) };
    like $@, qr/could not open \Q$bad_dev\E: /,
        "new() with an unopenable device path croaks with the path and errno";
    unlike $@, qr/bless non-reference/,
        "...and no longer dies with the bare 'bless non-reference' error";
}

# --- new(): ioctl failure croaks with the real cause, not "not found" ---

{
    # /dev/null opens fine but is not an I2C node, so the I2C_SLAVE_FORCE
    # ioctl fails (ENOTTY) - exercises the croak with no bus or device
    local $ENV{I2C_TESTING} = 0;
    eval { RPi::I2C->new(0x20, '/dev/null') };
    like $@, qr{ioctl\(I2C_SLAVE_FORCE\) failed for address 0x20 on /dev/null: },
        "new() on a non-I2C node croaks with the ioctl failure and errno";
    unlike $@, qr/not found/,
        "...and the misleading 'device not found' wording is gone";
}

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

    # read_bytes() accumulates and returns the documented array of N bytes,
    # ascending from the base register (was: a single scalar - only the
    # base-register byte - via a (0 << 8) overwrite)
    is_deeply [$obj->read_bytes(4, 0x10)], [0x10, 0x11, 0x12, 0x13],
        "read_bytes(4, 0x10) returns the documented 4-byte array, ascending from the base register";

    # write_word($value, [$reg]) matches write_byte() and its own POD
    # (was: ($reg, $value))
    $obj->write_word(0xABCD, 0x10);
    is_deeply [@write_args[1, 2]], [0x10, 0xABCD],
        "write_word(0xABCD, 0x10) sends (reg=0x10, value=0xABCD) - value first, register second";

    $obj->write_word(0xBEEF);
    is_deeply [@write_args[1, 2]], [0x00, 0xBEEF],
        "write_word(0xBEEF) defaults the register to 0x00 via _set_reg";

    # process($value, [$reg]) matches its POD and gets the _set_reg default
    # (was: ($reg, $value) with no default)
    my @process_args;
    local *RPi::I2C::_processCall = sub { @process_args = @_; return 0xFFFF; };
    $obj->process(0x1234, 0x20);
    is_deeply [@process_args[1, 2]], [0x20, 0x1234],
        "process(0x1234, 0x20) sends (reg=0x20, value=0x1234) - value first, register second";

    $obj->process(0x5678);
    is_deeply [@process_args[1, 2]], [0x00, 0x5678],
        "process(0x5678) defaults the register to 0x00 via _set_reg";

    # write_block() enforces the 32-byte SMBus block cap instead of letting
    # the bundled header silently truncate
    eval { $obj->write_block([ (1) x 33 ]) };
    like $@, qr/maximum of 32 bytes/,
        "write_block() with 33 bytes croaks instead of silently truncating";
}

done_testing();
