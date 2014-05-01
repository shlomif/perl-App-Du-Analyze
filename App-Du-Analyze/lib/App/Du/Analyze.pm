package App::Du::Analyze;

use strict;
use warnings;

use autodie;

our $VERSION = '0.0.2';

use MooX qw/late/;

use Getopt::Long qw( GetOptionsFromArray );
use Pod::Usage;

use App::Du::Analyze::Filter;

has argv => (isa => 'ArrayRef', is => 'rw');

sub run
{
    my ($self) = @_;

    my $prefix = "";
    my $depth = 1;
    my $sort = 1;
    my $man = 0;
    my $help = 0;
    my $version = 0;

    my @argv = @{$self->argv};

    GetOptionsFromArray(
        \@argv,
        "prefix|p=s" => \$prefix,
        "depth|d=n" => \$depth,
        "sort" => \$sort,
        "help|h" => \$help,
        "man" => \$man,
        "version" => \$version,
    ) or pod2usage(2);

    if ($help)
    {
        pod2usage(1)
    }

    if ($man)
    {
        pod2usage(-verbose => 2);
    }

    if ($version)
    {
        print "analyze-du.pl version $VERSION\n";
        exit(0);
    }

    my $in_fh;

    my $filename;
    if (!defined ($filename = $ENV{ANALYZE_DU_INPUT_FN}))
    {
        $filename = shift(@argv);
    }

    if (!defined($filename))
    {
        $in_fh = \*STDIN;
    }
    else
    {
        open $in_fh, '<', $filename;
    }

    App::Du::Analyze::Filter->new(
        {
            prefix => $prefix,
            depth => $depth,
            should_sort => $sort,
        }
    )->filter($in_fh, \*STDOUT);

    if (defined($filename))
    {
        close($in_fh);
    }

    return;
}

1;

=head1 NAME

App::Du::Analyze - analyze the output of du and find the most space-consuming
directories.

=head1 NOTE

Everything here is subject to change. The API is for internal use.

=head1 METHODS

=head2 my $app = App::Du::Analyze->new({argv => \@ARGV})

The constructor. Accepts the @ARGV array as a parameter and parses it.

=head2 $app->run()

Runs the application.

=cut

=cut
