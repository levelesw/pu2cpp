use strict;
use warnings;
use utf8;

use lib './lib';
use Template;
use Getopt::Long qw/:config
                    posix_default
                    no_ignore_case
                    gnu_compat/;

my $tt = Template->new({
    INCLUDE_PATH => './template/default',
    RELATIVE => 1,
    });

my $item = {
    class_name => 'CxxHogeHoge',
    class_namespace => 'aaa',
    public_methods => [
        {
            name => "Method1",
            return => "bool",
            args => [
                {
                    type => 'int',
                    name => 'x',
                },
                {
                    type => 'bool',
                    name => 'y',
                },
            ],
            is_const => 1,
            is_virtual => 1,
        }
    ],
    private_methods => [
        {
            name => "PrivateMethod1",
            return => "double",
            args => [
                {
                    type => 'int',
                    name => 'x',
                },
                {
                    type => 'int',
                    name => 'y',
                },
            ],
            is_virtual => 0,
            is_const => 0,
        }
    ]
};

my $item2 = {
    class_name => 'IxxHogeHoge',
    public_methods => [
        {
            name => "Method1",
            return => "bool",
            args => [
                
            ],
            is_virtual => 1,
            is_const => 1,
        }
    ],
};

$tt->process('cpp.tt', $item, 'output/cpp.cpp') or die $@;
$tt->process('hpp.tt', $item, 'output/hpp.h') or die $@;
$tt->process('ihpp.tt', $item2, 'output/ihpp.h') or die $@;

1;
