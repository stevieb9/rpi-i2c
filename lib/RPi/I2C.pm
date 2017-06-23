package RPi::I2C;

use strict;
use warnings;

our $VERSION = '2.3602';
our @ISA = qw(IO::Handle);
 
use Carp;
use IO::File;
use Fcntl;
 
require XSLoader;
XSLoader::load('RPi::I2C', $VERSION);
 
use constant I2C_SLAVE_FORCE => 0x0706;

sub new {
    my ($class, $addr, $dev) = @_;

    if (! defined $addr || $addr !~ /^\d+$/){ 
        croak "new() requires the \$addr param, as an integer";
    }
   
    $dev = defined $dev ? $dev : '/dev/i2c-1';

    my $fh = IO::File->new($dev, O_RDWR);
    
    my $self = bless $fh, $class;

    if ($self->ioctl(I2C_SLAVE_FORCE, int($addr)) < 0){
        printf("Device 0x%x not found\n", $addr);
        exit 1;
    }
    
    return $self;
}        
sub process {
    my ($self, $register_address, $value) = @_;
    return _processCall($self->fileno, $register_address, $value);
}
sub check_device {
    my ($self, $addr) = @_;
    return _checkDevice($self->fileno, $addr);
}
sub file_error {
    return $_[0]->error;
}
sub read {
    return _readByte($_[0]->fileno);
}
sub write {
    my ($self, $value) = @_;
    my $retval = _writeByteData($self->fileno, $value);
}
sub read_byte {
    my ($self, $register_address) = @_;
    return _readByteData($self->fileno, $register_address);
}
sub write_byte {
    my ($self, $reg, $value) = @_;
    return _writeByteData($self->fileno, $reg, $value);
}
sub read_bytes {
    my ($self, $reg, $num_bytes) = @_;
    my $retval = 0;
    for (1..$num_bytes){
        $retval = (0 << 8) | _readByteData($self->fileno, $reg + $num_bytes - $_)
    }
    return $retval;
}
sub write_bytes {
    my ($self, $register_address, $value) = @_;
    return _writeByteData($self->fileno, $register_address, $value);
}
sub read_word {
    my ($self, $register_address) = @_;
    return _readWordData($self->fileno, $register_address);
}
sub write_word {
    my ($self, $register_address, $value) = @_;
    return _writeWordData($self->fileno, $register_address, $value);
}
sub read_block {
    my ($self, $register_address, $num_bytes) = @_;
    my $read_val = '0' x ($num_bytes);
    my $retval = _readI2CBlockData($self->fileno, $register_address, $read_val);
    my @return = unpack( "C*", $read_val );
    return @return;
}
sub write_block {
    my ($self, $register_address, $values) = @_;
    my $value = pack "C*", @{$values};
    return _writeI2CBlockData($self->fileno, $register_address, $value);
}
sub DESTROY {
    $_[0]->close if defined $_[0]->fileno;
}

sub __placeholder {} # vim folds

1;
__END__

=head1 NAME

RPi::I2C - Interface to the I2C bus

=head1 SYNOPSIS

=head1 NOTES

#FIXME: items to document
- for arduino:
    ram=i2c_arm=on
    dtparam=i2c_arm_baudrate=10000

=head1 DESCRIPTION


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
