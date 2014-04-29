#!/usr/bin/perl

use strict;
use warnings;

use autodie;

use File::Spec;

use Test::More tests => 4;

use Test::Differences qw( eq_or_diff );

use App::Du::Analyze::Filter;

# TEST:$test_filter_on_fc_solve=1;
sub test_filter_on_fc_solve
{
    my ($options, $expected_output, $blurb) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $obj = App::Du::Analyze::Filter->new($options);

    open my $in_fh, '<:encoding(utf8)', File::Spec->catfile(File::Spec->curdir, 't', 'data', 'fc-solve-git-du-output.txt');

    my $buffer = '';
    open my $out_fh, '>', \$buffer;

    $obj->filter($in_fh, $out_fh);

    close($in_fh);
    close($out_fh);

    return eq_or_diff(
        $buffer,
        $expected_output,
        $blurb,
    );
}

{

    # TEST*$test_filter_on_fc_solve
    test_filter_on_fc_solve(
        {
            prefix => '',
            depth => 0,
        },
        <<"EOF", "depth 0 and no prefix",
119224\t
EOF
    );

    # TEST*$test_filter_on_fc_solve
    test_filter_on_fc_solve(
        {
            prefix => 'fc-solve',
            depth => 0,
        },
        <<"EOF", "depth 0 and specified prefix",
52532\tfc-solve
EOF
    );

    # TEST*$test_filter_on_fc_solve
    test_filter_on_fc_solve(
        {
            prefix => 'fc-solve',
            depth => 1,
        },
        <<"EOF", "depth 1 and specified prefix",
16\tfc-solve/tests
120\tfc-solve/docs
172\tfc-solve/scripts
232\tfc-solve/arch_doc
276\tfc-solve/rejects
392\tfc-solve/benchmarks
2920\tfc-solve/site
4192\tfc-solve/source
44208\tfc-solve/presets
EOF
    );

    # TEST*$test_filter_on_fc_solve
    test_filter_on_fc_solve(
        {
            prefix => '',
            depth => 1,
        },
        <<"EOF", "depth 1 and an empty prefix",
72\tTask-FreecellSolver-Testing
172\text-ifaces
6900\twww-solitaire
7512\tcpan
52012\t.git
52532\tfc-solve
EOF
    );
}
