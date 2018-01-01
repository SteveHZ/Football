package Euro::View;

#	Euro::View.pm 27/06/17

use Euro::Spreadsheets::Teams;
use Euro::Spreadsheets::Tables;
use Euro::Spreadsheets::Predictions;
use Euro::Spreadsheets::Extended;
use Euro::Spreadsheets::Goal_Expect_View;
use Euro::Spreadsheets::Goal_Diffs_View;
use Euro::Spreadsheets::Match_Odds_View;
use Euro::Spreadsheets::Over_Under_View;
use Euro::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

extends 'Football::View';

sub create_sheets {
	my $self = shift;

	$self->{xlsx_predictions} = Euro::Spreadsheets::Predictions->new ();
	$self->{xlsx_extended} = Euro::Spreadsheets::Extended->new ();
	$self->{xlsx_goal_expect} = Euro::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Euro::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Euro::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Euro::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Euro::Spreadsheets::Skellam_Dist_View->new ();
}

sub destroy_sheets {
	my $self = shift;

	$self->{xlsx_teams}->{$_}->{workbook}->close () for keys %{ $self->{xlsx_teams}};	
	$self->{xlsx_tables}->{$_}->{workbook}->close () for keys %{ $self->{xlsx_tables}};	
	$self->{xlsx_predictions}->{workbook}->close ();
	$self->{xlsx_extended}->{workbook}->close ();
	$self->{xlsx_goal_expect}->{workbook}->close ();
	$self->{xlsx_goal_diffs}->{workbook}->close ();
	$self->{xlsx_match_odds}->{workbook}->close ();
	$self->{xlsx_over_under}->{workbook}->close ();
	$self->{xlsx_skellam}->{workbook}->close ();
}

sub create_new_teams_sheet {
	my ($self, $filename) = @_;
	return Euro::Spreadsheets::Teams->new (filename => $filename);
}

sub create_new_tables_sheet {
	my ($self, $filename) = @_;
	return Euro::Spreadsheets::Tables->new (filename => $filename);
}

#	Not implemented by Euro::View

sub do_favourites {};
sub do_head2head {}
sub do_league_places {}

1;
