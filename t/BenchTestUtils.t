#   BenchTestUtils.t 28/01/19

use strict;
use warnings;
use Test::More;
use Football::BenchTest::Utils qw(get_league make_csv_file_list make_file_list);
use Football::Globals qw(@csv_leagues);
use Football::Model;

plan tests => 3;

subtest 'get_league' => sub {
    plan tests => 3;
    my $model = Football::Model->new ();
    my $fixture_list = $model->get_fixtures ();
    my $fixtures = get_league ($fixture_list, 'Championship');

    isa_ok ($fixtures, 'ARRAY', '@$fixtures is an array');
    isa_ok (@$fixtures[0], 'HASH', '@$fixtures[0] is a hash');
    is (@$fixtures[0]->{league}, 'Championship', 'league is Championship');
};

subtest 'make_csv_file_list' => sub {
    plan tests => 1;
    my $files = make_csv_file_list "C:/Mine/perl/Football/data", \@csv_leagues;
    is (@$files[0], 'C:/Mine/perl/Football/data/E0.csv', 'make_csv_file_list');
};

subtest 'make_file_list' => sub {
    plan tests => 1;
    my @file_list = qw(E0.csv E1.csv E2.csv);
    my $files = make_file_list "C:/Mine/perl/Football/data", \@file_list;
    is (@$files[0], 'C:/Mine/perl/Football/data/E0.csv', 'make_file_list');
};
