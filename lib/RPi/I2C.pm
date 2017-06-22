package RPi::I2C;

use strict;
use warnings;

use parent 'WiringPi::API';

our $VERSION = '2.3602';

use constant DEFAULT_REGISTER => 0x00;

sub new {
    my ($class, $addr) = @_;
    my $self = bless {}, $class;
    my $fd = $self->i2c_setup($self->addr($addr));
    $self->fd($fd);
}
sub read {
    $_[0]->i2c_read($_[0]->fd);
}
sub read_byte {
    my ($self, $reg) = @_;
    $reg = DEFAULT_REGISTER if ! defined $reg;
    $self->i2c_read_byte($self->fd, $reg);
}
sub read_word {
    my ($self, $reg) = @_;
    $reg = DEFAULT_REGISTER if ! defined $reg;
    $self->i2c_read_word($self->fd, $reg);
}
sub write {
    $_[0]->i2c_write($_[0]->fd, $_[1]);
}
sub write_byte {
    my ($self, $data, $reg) = @_;
    $reg = DEFAULT_REGISTER if ! defined $reg;
    $self->i2c_write_byte($self->fd, $reg, $data);
}
sub write_word {
    my ($self, $data, $reg) = @_;
    $reg = DEFAULT_REGISTER if ! defined $reg;
    $self->i2c_write_word($self->fd, $reg, $data);

}
sub addr {
    $_[0]->{addr} = $_[1] if @_ > 1;
    return $_[0]->{addr};
}
sub fd {
    $_[0]->{fd} = $_[1] if @_ > 1;
    return $_[0]->{fd};
}

sub _placeholder {} # vim folds

1;
__END__

=head1 NAME

RPi::I2C - Interface to the I2C bus on the Raspberry Pi

=head1 SYNOPSIS

    use RPi::I2C;

    my $addr = 0x3c;
    my $data = 0xFF;

    my $i2c_dev = RPi::I2C->new($addr);

    # simple byte write/read (default register, 0x00)

    $i2c_dev->write($data);
    my $byte = $i2c_dev->read;

    # write and read byte from specific register

    # ...the register does not have to be specified
    # if you're using the default (0x00)

    my $register = 0x01;

    $i2c_dev->write_byte($data, $register);
    $byte = $i2c_dev->read_byte($register);

    # write and read two bytes (word) from specific register

    $i2c_dev->write_word($data, $register);
    my $word = $i2c_dev->read_word($register);

=head1 DESCRIPTION

Interface to the I2C bus. This API is designed to operate on the Raspberry Pi
platform, but should work on other devices, possibly with some tweaking.

Requires L<wiringPi|http://wiringpi.com> v2.36+ to be installed.

=head1 METHODS

=head2 new($addr)

Instantiates a new I2C device object ready to be read from and written to.

Parameters:

    $addr

Mandatory, Integer (in hex): The address of the device on the I2C bus
(C<i2cdetect -y 1>). eg: C<0x78>.

=head2 read

Performs a simple read of a single byte from the device, and returns it.

=head2 read_byte($reg)

Same as L</read>, but allows you to optionally specify a specific device
register to read from.

Parameters:

    $reg

Optional, Integer: The device's register to read from. eg: C<0x01>. Defaults to
C<0x0>.

=head2 read_word($reg)

Same as C<read_byte()>, but reads two bytes (16-bit word) instead.

=head2 write($data)

Performs a simple write of a single byte to the I2C device.

Parameters:

    $data

Mandatory, 8-bit unsigned integer: The byte to send to the device.

=head2 write_byte($data, $reg)

Same as C<write()>, but allows you to optionally specify a specific device
register to write to.

Parameters:

    $data

Mandatory, 8-bit unsigned integer: The byte to send to the device.

    $reg

Optional, Integer: The device's register to write to. eg: C<0x01>. Defaults
to C<0x0>.

=head2 write_word($data, $reg)

Same as C<write_byte()>, but writes two bytes (16-bit word) instead.

=head2 fd

Returns the file descriptor of the I2C channel. Do not send anything into this
method. It is for read convenience only.

=head2 addr

Returns the I2C bus address of the current I2C device object. Do not send
anything into this method, or else you'll lose communication with the device.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2017 by Steve Bertrand

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.
