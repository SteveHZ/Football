package Rugby::View;

#	View.pm 03/02/16
#	v1.1 05-06/05/17

use Rugby::Spreadsheets::Teams;
use Rugby::Spreadsheets::Tables;
use Rugby::Spreadsheets::Predictions;
use Rugby::Spreadsheets::Extended;
use Rugby::Spreadsheets::Points_Expect_View;
use Rugby::Spreadsheets::Points_Diff_View;
use Rugby::Spreadsheets::Match_Odds_View;
use Rugby::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

extends 'Football::View';

sub create_sheets {
	my $self = shift;

	$self->{xlsx_predictions} = Rugby::Spreadsheets::Predictions->new ();
	$self->{xlsx_extended} = Rugby::Spreadsheets::Extended->new ();
	$self->{xlsx_goal_expect} = Rugby::Spreadsheets::Points_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Rugby::Spreadsheets::Points_Diff_View->new ();
	$self->{xlsx_match_odds} = Rugby::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_skellam} = Rugby::Spreadsheets::Skellam_Dist_View->new ();
	$self->{xlsx_over_under} = Football::Spreadsheets::Over_Under_View->new ();
}

sub destroy_sheets {
	my $self = shift;

	$self->{xlsx_teams}->{$_}->{workbook}->close () for keys %{ $self->{xlsx_teams}};	
	$self->{xlsx_tables}->{$_}->{workbook}->close () for keys %{ $self->{xlsx_tables}};	
	$self->{xlsx_predictions}->{workbook}->close ();
	$self->{xlsx_extended}->{workbook}->close ();
	$self->{xlsx_goal_expect}->{workbook}->close ();
	$self->{xlsx_goal_diffs}->{workbook}->close ();
}

sub get_formats {
	my $self = shift;

	$self->{table_format} = "%27s %2s %2s %2s %3s %3s %4s %2s";
	$self->{table_header} = [ qw (P W L D F A PD Pts) ];
	$self->{main_table_format} = "\n%-24s %2d %2d %2d %2d %3d %3d %4d %3d";
	$self->{teams_format} = "\n%s : %-24s %s %-6s %s";
	$self->{homes_format} = "\n%-24s :";
	$self->{full_homes_format} = "\n%s : %-24s H %s  %s";
	$self->{full_aways_format} = "\n%s : %-24s A %s  %s";
	$self->{fixtures_format} = "\t%-24s v %-24s";
	$self->{fixtures_format2} = "  %2d-%d";
	
	$self->{league_places_format} = "%-24s v %-24s";
	$self->{league_places_format2} = "  %2d v %2d - Home Win : %2d Away Win : %2d Draw : %2d";
	$self->{goal_diff_format} = "  Goal Difference : %4d - Home Win : %3d Away Win : %3d Draw : %3d";
	$self->{recent_draws_format} = "%d : %-24s v %-24s";
	$self->{recent_draws_format2} = " Home : %2d Away : %2d : %s";

}

sub create_new_teams_sheet {
	my ($self, $filename) = @_;
	return Rugby::Spreadsheets::Teams->new (filename => $filename);
}

sub create_new_tables_sheet {
	my ($self, $filename) = @_;
	return Rugby::Spreadsheets::Tables->new (filename => $filename);
}

sub do_match_odds {
	my ($self, $fixtures) = @_;
	$self->{xlsx_skellam}->view ($fixtures->{skellam});
	$self->{xlsx_match_odds}->view ($fixtures->{match_odds});
}

#	Not implemented by Rugby::View

sub do_recent_draws {};
sub do_favourites {};
sub do_over_under {};

1;
