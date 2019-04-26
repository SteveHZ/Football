package Football::Game_Predictions::Summer;

#	Summer::View.pm 27/06/17

use Summer::Spreadsheets::Goal_Expect_View;
use Summer::Spreadsheets::Goal_Diffs_View;
use Summer::Spreadsheets::Match_Odds_View;
use Summer::Spreadsheets::Over_Under_View;
use Summer::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::UK';

sub create_sheets {
	my $self = shift;

	$self->{xlsx_goal_expect} = Summer::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Summer::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Summer::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Summer::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Summer::Spreadsheets::Skellam_Dist_View->new ();
}

#	Not implemented by Summer::View

#sub do_favourites {};
#sub do_head2head {}
#sub do_league_places {}

1;
