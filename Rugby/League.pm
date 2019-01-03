package Rugby::League;

#	Rugby::League.pm 23/02/16
#	Mouse version 04/05/16
#	v 1.1 04-05/05/17

use Rugby::Table;
use Rugby::HomeTable;
use Rugby::AwayTable;

use Moo;
use namespace::clean;

extends 'Football::League';

sub BUILD {
	my $self = shift;
	$self->{points} = { W => 2, D => 1, L => 0, };
}

sub create_new_table {
	my $self = shift;
	return Rugby::Table->new (
		teams => $self->{team_list}
	);
}

sub create_new_home_table {
	my $self = shift;
	return Rugby::HomeTable->new (
		teams => $self->{team_list}
	);
}

sub create_new_away_table {
	my $self = shift;
	return Rugby::AwayTable->new (
		teams => $self->{team_list}
	);
}

1;
