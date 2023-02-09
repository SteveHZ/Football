#	MyPoisson.t 02/07/17, 28/07/17

use strict;
use warnings;
use Test2::V0;
plan 3;

use lib 'C:/Mine/perl/Football';
use Football::Game_Predictions::MyPoisson;
use Football::Game_Predictions::Match_Odds;

my $p = Football::Game_Predictions::MyPoisson->new ( max => 10 );
my $game = Football::Game_Predictions::Match_Odds->new ( max => 10 );

subtest 'constructors' => sub {
	plan 2;
	isa_ok ($p, ['Football::Game_Predictions::MyPoisson'], '$p');
	isa_ok ($game, ['Football::Game_Predictions::Match_Odds'], '$game');
};

my $home_score = 2;
my $away_score = 0;
my $home_expect = 2.02;
my $away_expect = 0.53;

subtest 'MyPoisson Test' => sub {
	plan 1;

	my %away_cache;
	for my $home_goals (0..10) {
		printf "\n%2d : ", $home_goals;
		my $home = $p->poisson ($home_expect, $home_goals);
		for my $away_goals (0..10) {
			unless (exists ( $away_cache{$away_goals} )) {
				$away_cache{$away_goals} = $p->poisson ($away_expect, $away_goals);
			}
			my $result = $p->poisson_result ($home, $away_cache{$away_goals});
			print "$result\t";
		}
	}
	print "\n\n";

	my $home = $p->poisson ($home_expect, $home_score);
	my $away = $p->poisson ($away_expect, $away_score);
	my $result = $p->poisson_result ($home, $away);

	is ($result, 15.93, 'poisson_result for 2-0 = 15.93');
};

subtest 'Match Odds Test' => sub {
	plan 7;
	$game->calc ($home_expect, $away_expect);

	is ($game->home_win_odds, 		1.38 , 'Home win Odds = 1.38');
	is ($game->away_win_odds, 		11.61, 'Away win Odds = 11.61');
	is ($game->draw_odds, 			5.35 , 'Draw odds = 5.35');
	is ($game->both_sides_yes_odds, 2.8  , 'Both Sides Yes = 2.8');
	is ($game->both_sides_no_odds, 	1.55 , 'Both Sides No = 1.55');
	is ($game->under_2pt5_odds, 	1.88 , 'Under 2.5 = 1.88');
	is ($game->over_2pt5_odds, 		2.13 , 'Over 2.5 = 2.13');
};

=begin comment
subtest 'Weighted' => sub {
	plan 1;
	is (1,1,"ok");

	for my $home_score (0..10) {
		print "\n";
		for my $away_score (0..10) {
			my $home = $p->poisson ($home_expect, $home_score);
			my $away = $p->poisson ($away_expect, $away_score);
			my $result = $p->poisson_result ($home, $away);
			print " $result,"
		}
	}
	print "\n\n";
	for my $home_score (0..10) {
		print "\n";
		for my $away_score (0..10) {
			my $home = $p->poisson_weighted ($home_expect, $home_score);
			my $away = $p->poisson_weighted ($away_expect, $away_score);
			my $result = $p->poisson_result ($home, $away);
			print " $result,"
		}
	}
	print "\n\n";
};

=end comment
=cut