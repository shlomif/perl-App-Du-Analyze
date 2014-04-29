package App::Du::Analyze::Filter;

use strict;
use warnings;

use MooX qw/late/;

use List::MoreUtils qw/all/;

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

    my @prefix_to_test = split(m#/#, $prefix);

    while(my $line = <$in_fh>)
    {
        chomp($line);
        if (my ($size, $total_path, $path) = $line =~ m#\A(\d+)\t(\.(.*?))\z#)
        {
            my @path_to_test = split(m#/#, $total_path);
            # Get rid of the ".".
            shift(@path_to_test);

            if (
                (@path_to_test == @prefix_to_test + $depth)
                    and
                (all { $path_to_test[$_] eq $prefix_to_test[$_] } (0 .. $#prefix_to_test))
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

