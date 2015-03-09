package App::Du::Analyze::Filter;

use strict;
use warnings;

sub _my_all
{
    my $cb = shift;

    foreach my $x (@_)
    {
        if (not $cb->(local $_ = $x))
        {
            return 0;
        }
    }

    return 1;
}

sub new
{
    my $class = shift;

    my $self = bless {}, $class;

    $self->_init(@_);

    return $self;
}

sub _depth
{
    my $self = shift;

    if (@_)
    {
        $self->{_depth} = shift;
    }

    return $self->{_depth};
}

sub _prefix
{
    my $self = shift;

    if (@_)
    {
        $self->{_prefix} = shift;
    }

    return $self->{_prefix};
}

sub _should_sort
{
    my $self = shift;

    if (@_)
    {
        $self->{_should_sort} = shift;
    }

    return $self->{_should_sort};
}

sub _init
{
    my ($self, $args) = @_;

    $self->_prefix($args->{prefix});
    $self->_depth($args->{depth});
    $self->_should_sort(1);

    if (exists($args->{should_sort}))
    {
        $self->_should_sort($args->{should_sort});
    }

    return;
}

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
                (_my_all (sub { $path_to_test[$_] eq $prefix_to_test[$_] }, (0 .. $#prefix_to_test)))
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

