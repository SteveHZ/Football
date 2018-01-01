package Rugby::AwayTable;

#	Rugby::AwayTable.pm 03/05/16
# 	v 1.1 05/05/17

use Moo;
use namespace::clean;

extends 'Football::AwayTable';

sub do_away_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{won} ++;
	$self->{table}->{ $game->{away_team} }->{points} += 2;
}

1;