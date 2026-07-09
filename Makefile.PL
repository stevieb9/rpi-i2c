use 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker;

if ($^O ne 'linux') {
    warn "OS unsupported: RPi::I2C requires the Linux I2C interface " .
         "(/dev/i2c-*); it cannot be built on '$^O'.\n";
    exit 0;
}

# The I2C development-header presence check is the family-canonical check in
# RPi::Const::BuildCheck (pulled in via CONFIGURE_REQUIRES below). It honours
# RPI_DIST_RELEASE and exits 0 with a message before WriteMakefile when the
# headers are missing, so CPAN testers report NA, not FAIL.
eval {
    require RPi::Const::BuildCheck;
    RPi::Const::BuildCheck::i2c_build_check();
    1;
} or do {
    # No RPi::Const::BuildCheck (a bare `perl Makefile.PL` with no CPAN client
    # to honour CONFIGURE_REQUIRES). Stay NA-safe: exit 0 unless releasing.
    print "RPi::Const (the build-check dependency) is not installed; install " .
          "it first, or set RPI_DIST_RELEASE to skip the i2c check.\n";
    exit 0 if ! $ENV{RPI_DIST_RELEASE};
};

WriteMakefile(
    NAME             => 'RPi::I2C',
    AUTHOR           => q{Steve Bertrand <steveb@cpan.org>},
    VERSION_FROM     => 'lib/RPi/I2C.pm',
    ABSTRACT_FROM    => 'lib/RPi/I2C.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    INC              => "-I.",
    MIN_PERL_VERSION => 5.006,
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            bugtracker => {
                web => 'https://github.com/stevieb9/rpi-i2c/issues',
            },
            repository => {
                type => 'git',
                url => 'https://github.com/stevieb9/rpi-i2c.git',
                web => 'https://github.com/stevieb9/rpi-i2c',
            },
        },
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
        'RPi::Const'          => '1.07',
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'RPi-I2C-*' },
);
