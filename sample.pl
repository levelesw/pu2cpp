# this is just a simple script to extract class names from given plantuml source and export class template.
# Not validated enough and would generate erroneous files.
# [options]
#  --input or -i -> input file to parse (mandatory)
#  --source-ext or -o -> output dir (default "./out")
#  --source-ext or -s -> extention for C++ source files (default ".cpp")
#  --header-ext or -h -> extention for C++ header files (default ".h")
#  --template or -t -> template to use (default: "default")
#  --author or -a -> author (default: "")
use 5.010;
use strict;
use warnings;
use utf8;
use autodie;

use lib './lib';
use Template;
use Getopt::Long qw/:config
  posix_default
  no_ignore_case
  gnu_compat/;

my $input_file = '';          # UML source file
my $output_dir = './out';     # output dir
my $source_ext = 'cpp';       # extention for C++ source files
my $header_ext = 'h';         # extention for C++ header files
my $template   = 'default';
my $author     = '';
GetOptions(
    'input|i=s'      => \$input_file,
    'output|o=s'     => \$output_dir,
    'source-ext|s=s' => \$source_ext,
    'header-ext|h=s' => \$header_ext,
    'template|t=s'   => \$template,
    'author|a=s'     => \$author,
);

if ( $0 eq __FILE__ ) {
    main();
}

sub main {
    say "Generating C++ files from " . $input_file;

    my ( $classes_aref, $interfaces_aref ) = _parse($input_file);
    _export( $classes_aref, $interfaces_aref );
}

sub _parse {
    my $source_file = shift;
    say "Parse " . $source_file;

    my @lines;
    open my $fh, '<', "$source_file";
    @lines = split /\n/, do { local $/; <$fh> };
    close $fh;

    my $classes_aref    = [];
    my $interfaces_aref = [];

    for my $line (@lines) {
        if ( $line =~ /\s*(class|interface|abstract)\s+\"?([^\s"]+)\"?(.*)/ ) {
            my $type   = $1;
            my $name   = $2;
            my $option = $3 // "";

            say 'Found ' . $type . ' "' . $name . '".';

            my $as_name = undef;
            if ( $option =~ /as\s+([A-Za-z0-9_]+)/ ) {
                $as_name = $1;
            }

            my $template_types_aref = [];
            if ( $option =~ /(?<!<)<([^<>]+)>(?!>)/ ) {
                @{$template_types_aref} = split /,/, $1;
            }

            my $obj = {
                class_name           => $as_name // $name,
                name                 => $name,
                class_template_types => $template_types_aref,
                inheritance          => [],                     # not supported
                source_ext           => $source_ext,
                header_ext           => $header_ext,
                author               => $author,
            };

            if ( $type =~ /class|abstract/ ) {
                push @{$classes_aref}, $obj;
            }
            else {
                push @{$interfaces_aref}, $obj;
            }
        }
    }

    return ( $classes_aref, $interfaces_aref );
}

sub _export {
    my ( $classes_aref, $interfaces_aref ) = @_;

    if ( !-e $output_dir ) {
        mkdir $output_dir;
    }

    my $tt = Template->new(
        {
            INCLUDE_PATH => './template/' . $template,
            RELATIVE     => 1,
        }
    );

    for my $class ( @{$classes_aref} ) {
        if ( scalar @{ $class->{class_template_types} } == 0 ) {
            $tt->process( 'cpp.tt', $class,
                $output_dir . '/' . $class->{class_name} . '.' . $source_ext )
              or die $@;
        }
        $tt->process( 'hpp.tt', $class,
            $output_dir . '/' . $class->{class_name} . '.' . $header_ext )
          or die $@;
    }

    for my $class ( @{$interfaces_aref} ) {
        $tt->process( 'ihpp.tt', $class,
            $output_dir . '/' . $class->{class_name} . '.' . $header_ext )
          or die $@;
    }
}

1;

__END__
    my $item = {
        class_name           => 'CxxHogeHoge',
        class_namespace      => '',
        class_template_types => [ 'T', 'U' ],
        inheritance          => [
            {
                class         => 'CBase',
                accessibility => 'public',
            },
            {
                class         => 'IBase',
                accessibility => 'public',
            }
        ],
        public_methods => [
            {
                name   => "Method1",
                return => "bool",
                args   => [
                    {
                        type => 'int',
                        name => 'x',
                    },
                    {
                        type => 'bool',
                        name => 'y',
                    },
                ],
                is_const   => 1,
                is_virtual => 1,
            }
        ],
        private_methods => [
            {
                name   => "PrivateMethod1",
                return => "double",
                args   => [
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
                is_const   => 0,
            }
        ]
    };

    my $item2 = {
        class_name           => 'IxxHogeHoge',
        class_template_types => ['T'],
        inheritance          => [
            {
                class         => 'IBase',
                accessibility => 'public',
            }
        ],
        public_methods => [
            {
                name   => "Method1",
                return => "bool",
                args   => [

                ],
                is_virtual => 1,
                is_const   => 1,
            }
        ],
    };
