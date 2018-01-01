package Rugby::HomeTable;

# 	Rugby::HomeTable.pm 03/05/16
# 	v 1.1 05/05/17

use Moo;
use namespace::clean;
 
extends 'Football::HomeTable';

sub do_home_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{won} ++;
	$self->{table}->{ $game->{home_team} }->{points} += 2;
}

1;