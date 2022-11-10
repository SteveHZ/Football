package Football::Spreadsheets::Recent_Match_Odds_View;

use Football::Globals qw($reports_folder);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$reports_folder/Recent Match Odds UK.xlsx";
}

#	Season Match Odds have already been written out by Football::Spreadsheets::Match_Odds_View::view,
#	Could also write out Recent Match Odds here, but don't want to write out a second set of odds when running predict.pl
sub view {
	my ($self, $fixtures) = @_;
	$self->do_match_odds ($fixtures);
}

sub match_rows {
	my ($self, $game) = @_;
	return
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff_last_six} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff_last_six} ) },
}

sub hwd_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{last_six}->{home_win} => $self->{float_format} },
		{ $game->{odds}->{last_six}->{draw} => $self->{float_format} },
		{ $game->{odds}->{last_six}->{away_win} => $self->{float_format} },
}

sub over_under_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{last_six}->{over_2pt5} => $self->{float_format} },
		{ $game->{odds}->{last_six}->{under_2pt5} => $self->{float_format} },
}

sub double_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{last_six}->{home_double} => $self->{float_format} },
		{ $game->{odds}->{last_six}->{away_double} => $self->{float_format} },
}

sub bsts_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{last_six}->{both_sides_yes} => $self->{float_format} },
		{ $game->{odds}->{last_six}->{both_sides_no} => $self->{float_format} },
}

1;
