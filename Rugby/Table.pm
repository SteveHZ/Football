package Rugby::Table;

#	Rugby::Table.pm 03/05/16
#	v 1.1 04/05/17

use Moo;
use namespace::clean;

extends 'Football::Table';

sub do_home_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{won} ++;
	$self->{table}->{ $game->{home_team} }->{points} += 2;
	$self->{table}->{ $game->{away_team} }->{lost} ++;
}

sub do_away_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{won} ++;
	$self->{table}->{ $game->{away_team} }->{points} += 2;
	$self->{table}->{ $game->{home_team} }->{lost} ++;
}

1;
