
#	pdl_odds_bench.pl 12/10/17

use strict;
use warnings;
use Benchmark qw(cmpthese timethese);

use lib 'C:/Mine/perl/Football';
use Football::Match_Odds;
use Football::Match_Odds_pdl;

my $home_expect = 2.02;
my $away_expect = 0.53;

my $t = timethese ( -10, {
	'Pure perl test' 	=> sub { perl_odds (); },
	'PDL test'			=> sub { pdl_odds (); },
});
cmpthese $t;

sub perl_odds {
	my $perl_game = Football::Match_Odds->new ( max => 10 );
	$perl_game->calc ($home_expect, $away_expect);

#	my $home_win = $perl_game->home_win_odds ();
#	my $away_win = $perl_game->away_win_odds ();
#	my $draw = $perl_game->draw_odds ();
#	my $both_sides_yes = $perl_game->both_sides_yes_odds ();
#	my $both_sides_no = $perl_game->both_sides_no_odds ();
#	my $under_2pt5 = $perl_game->under_2pt5_odds ();
#	my $over_2pt5 = $perl_game->over_2pt5_odds ();
}

sub pdl_odds {
	my $pdl_game = Football::Match_Odds_pdl->new ( max => 10 );
	$pdl_game->calc ($home_expect, $away_expect);
	
#	my $home_win = $pdl_game->home_win_odds ();
#	my $away_win = $pdl_game->away_win_odds ();
#	my $draw = $pdl_game->draw_odds ();
#	my $both_sides_yes = $pdl_game->both_sides_yes_odds ();
#	my $both_sides_no = $pdl_game->both_sides_no_odds ();
#	my $under_2pt5 = $pdl_game->under_2pt5_odds ();
#	my $over_2pt5 = $pdl_game->over_2pt5_odds ();
}
