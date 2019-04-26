package Football::Game_Predictions::Euro;

#	Euro::View.pm 27/06/17

use Euro::Spreadsheets::Goal_Expect_View;
use Euro::Spreadsheets::Goal_Diffs_View;
use Euro::Spreadsheets::Match_Odds_View;
use Euro::Spreadsheets::Over_Under_View;
use Euro::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::UK';

sub create_sheets {
	my $self = shift;

	$self->{xlsx_goal_expect} = Euro::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Euro::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Euro::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Euro::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Euro::Spreadsheets::Skellam_Dist_View->new ();
}

#	Not implemented by Euro::View

#sub do_favourites {};
#sub do_head2head {}
#sub do_league_places {}

1;
