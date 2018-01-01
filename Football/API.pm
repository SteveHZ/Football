package Football::API;

#	Football::API.pm 03/07/16

use Mouse;
use namespace::autoclean;

use MyLib qw (date_where multi_where);
use Football::Football_Data_Model;

sub BUILD {
	my $self = shift;
	$self->{data_model} = Football::Football_Data_Model->new ();
}

sub get_league {
	my ($self, $league) = @_;
	return $self->{data_model}->update ($league);
}

sub get_homes {
	my ($self, $league, $team, $order) = @_;
	$order //= "asc";
	return $self->get_team ($league, $team, "home", $order);
}

sub get_aways {
	my ($self, $league, $team, $order) = @_;
	$order //= "asc";
	return $self->get_team ($league, $team, "away", $order);
}

sub get_team {
	my ($self, $league, $team, $home_away, $order) = @_;

	return date_where (
		db => $self->{data_model}->update ($league),
		field => $home_away."_team",
		data => $team,
		sort_by => "date",
		order => $order,
	);
}

sub get_all {
	my ($self, $league, $team, $order) = @_;
	$order //= "asc";

	return multi_where (
		db => $self->{data_model}->update ($league),
		fields => [ qw(home_team away_team) ],
		data => $team,
		sort_by => "date",
		order => $order,
	);
}

1;