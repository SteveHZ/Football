#	Team.t 05/06/16

use strict;
use warnings;
use Test::More tests => 2;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Football::Team;
use Football::Globals qw( $default_stats_size );

my $team = Football::Team->new ();

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($team, 'Football::Team', '$team');
};

subtest 'splice_array' => sub {
	plan tests => $default_stats_size;

	$team->{games} = [
		{ date => '01/02/16', opponent => 'Liverpool', 	score => '2-0', home_away => 'H', result => 'W' },
		{ date => '02/02/16', opponent => 'Chelsea', 	score => '0-1', home_away => 'H', result => 'L' },
		{ date => '03/02/16', opponent => 'Arsenal', 	score => '1-1', home_away => 'H', result => 'D' },
		{ date => '04/02/16', opponent => 'Everton', 	score => '4-1', home_away => 'H', result => 'W' },
		{ date => '05/02/16', opponent => 'Leicester', 	score => '2-1', home_away => 'H', result => 'W' },
		{ date => '06/02/16', opponent => 'Stoke',	 	score => '0-6', home_away => 'H', result => 'L' },
	];

	for my $games (1..$default_stats_size) {
		my $copy = [];
		for my $idx (0..$default_stats_size - 1) {
			push (@$copy, $team->{games}[$idx]);
		}

		my $expect = [];
		for my $idx ((6 - $games)..$default_stats_size - 1) {
			push (@$expect, @$copy[$idx] );
		}

		my $stats = $team->splice_array ($copy, $games);
		cmp_deeply ($stats, $expect, "splice array $games");
	}
};
