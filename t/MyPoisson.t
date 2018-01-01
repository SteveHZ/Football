#!	C:/Strawberry/perl/bin

#	MyPoisson.t 02/07/17, 28/07/17

use strict;
use warnings;
use Test::More tests => 3;

use lib "C:/Mine/perl/Football";
use Football::MyPoisson;
use Football::Match_Odds;

my $p = Football::MyPoisson->new ();
my $game = Football::Match_Odds->new ( max => 10 );

subtest 'constructors' => sub {
	plan tests => 2;
	isa_ok ($p, 'Football::MyPoisson', '$p');
	isa_ok ($game, 'Football::Match_Odds', '$game');
};

my $home_score = 7;
my $away_score = 0;
my $home_expect = 2.02;
my $away_expect = 0.53;

subtest 'MyPoisson Test' => sub {
	plan tests => 2;
	
	my $expect = 2.5;
	my $score = 4;
	my $prob =  $p->poisson ($expect, $score);
	is ($prob, 0.133602110450453, "poisson 0.133602110450453");

	my $home = $p->poisson ($home_expect, $home_score);
	my $away = $p->poisson ($away_expect, $away_score);
	my $result = $p->poisson_game ($home, $away);

	is ($result, 0.213, "poisson_game 0.213");
};

subtest 'Match Odds Test' => sub {
	plan tests => 7;
	$game->calc ($home_expect, $away_expect);

	my $home_win = $game->home_win_odds ();
	my $away_win = $game->away_win_odds ();
	my $draw = $game->draw_odds ();
	my $both_sides_yes = $game->both_sides_yes_odds ();
	my $both_sides_no = $game->both_sides_no_odds ();
	my $under_2pt5 = $game->under_2pt5_odds ();
	my $over_2pt5 = $game->over_2pt5_odds ();

	is ($home_win, 1.38, "Home win Odds = 1.38");
	is ($away_win, 11.6, "Away win Odds = 11.6");
	is ($draw, 5.35, "Draw odds = 5.35");
	is ($both_sides_yes, 2.8, "Both Sides Yes = 2.8");
	is ($both_sides_no, 1.55, "Both Sides No = 1.55");
	is ($under_2pt5, 1.88, "Under 2.5 = 1.88");
	is ($over_2pt5, 2.13, "Over 2.5 = 2.13");
};
