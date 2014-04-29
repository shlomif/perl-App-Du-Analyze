package App::Du::Analyze::Filter;

use strict;
use warnings;

use MooX qw/late/;

has '_prefix' => (isa => 'Str', is => 'ro', init_arg => 'prefix');
has '_depth' => (isa => 'Int', is => 'ro', init_arg => 'depth');
has '_should_sort' => (isa => 'Bool', is => 'ro', init_arg => 'should_sort',
default => sub { 1; },);

sub filter
{
    my ($self, $in_fh, $out_fh) = @_;

    my $prefix = $self->_prefix;
    my $sort = $self->_should_sort;
    my $depth = $self->_depth;

    my $compare_depth = $depth - 1;
    my @results;

    $prefix =~ s#/+\z##;

    my $prefix_to_test = "$prefix/";
    if (! length($prefix))
    {
        $prefix_to_test = "";
    }

    while(my $line = <$in_fh>)
    {
        chomp($line);
        if (my ($size, $total_path, $path) = $line =~ m#\A(\d+)\t(\./?(.*?))\z#)
        {
            my $path_to_test = $path;
            if (
                $depth
                ? (
                    ( $path_to_test =~ s#\A$prefix_to_test##)
                    && (($path_to_test =~ tr{/}{/}) == $compare_depth)
                )
                : length($prefix)
                ? ($total_path eq "./$prefix")
                : ($total_path eq ".")
            )
            {
                $path =~ s#\A/##;
                push @results, [$path, $size];
            }
        }
    }

    if ($sort)
    {
        @results = (sort { $a->[1] <=> $b->[1] } @results);
    }

    foreach my $r (@results)
    {
        print {$out_fh} "$r->[1]\t$r->[0]\n";
    }

    return;
}

1;

=head1 NAME

App::Du::Analyze::Filter - filter algorithm for L<App::Du::Analyze>

=head1 NOTE

Everything here is subject to change. The API is for internal use.

=head1 METHODS

=head2 App::Du::Analyze::Filter->new()

Accepted arguments:

=over 4

=item * prefix

The prefix of the path to filter.

=item * depth

The number of directory components below. Defaults to 1.

=item * should_sort

Should the items be sorted. A boolean that defaults to 0.

=back

=head2 $obj->filter($in_fh, $out_fh)

Filter the input from $in_fh (a readonly or readwrite filehandle), which
is the output of du, and output it to $out_fh .

=cut

