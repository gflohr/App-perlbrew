#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::More;
use Test::Output;

mock_perlbrew_install("perl-5.12.3");
mock_perlbrew_install("perl-5.12.4");
mock_perlbrew_install("perl-5.14.1");
mock_perlbrew_install("perl-5.14.2");

subtest "perlbrew version" => sub {
    my $app = App::perlbrew->new();
    my $version = $App::perlbrew::VERSION;
    stdout_is(
        sub {
            $app->run_command('version');
        },
        "t/05.get_current_perl.t  - App::perlbrew/$version\n"
    );
};

subtest "Current perl is decided from environment variable PERLBREW_PERL" => sub {
    for my $v (qw(perl-5.12.3 perl-5.12.3 perl-5.14.1 perl-5.14.2)) {
        local $ENV{PERLBREW_PERL} = $v;
        my $app = App::perlbrew->new;
        is $app->current_perl, $v;
    }
};

my $current = file($App::perlbrew::PERLBREW_HOME, "version");

ok !-f $current;
is $app->current_perl, "";

io($current)->print("perl-5.12.3");
ok -f $current;
is $app->current_perl, "perl-5.12.3";

io($current)->print("perl-5.14.2");
is $app->current_perl, "perl-5.14.2";

io($current)->print('perl-5.14.2@abcd');
is $app->current_perl, 'perl-5.14.2@abcd';

done_testing;
