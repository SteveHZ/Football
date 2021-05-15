package Football::Roles::Team_Data;

use Moo::Role;

requires qw(table homes aways last_six);

sub goal_diff {
	my ($self, $team) = @_;
	return $self->{table}->goal_diff ($team);
}

sub recent_goal_diff {
	my ($self, $team) = @_;
	return $self->{table}->recent_goal_diff ($team);
}

sub position {
	my ($self, $team) = @_;
	return $self->{table}->position ($team);
}

sub get_for {
	my ($self, $team) = @_;
	return $self->{table}->for ($team);
}

sub get_against {
	my ($self, $team) = @_;
	return $self->{table}->against ($team);
}

# Homes

sub get_homes {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{homes};
}

sub get_full_homes {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{full_homes};
}

sub get_home_over_under {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{home_over_under};
}

sub get_home_points {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{points};
}

sub get_home_draws {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{draws};
}

sub get_home_goal_diff {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{goal_difference};
}

sub get_home_for {
	my ($self, $team) = @_;
	return $self->{home_table}->for ($team);
}

sub get_home_against {
	my ($self, $team) = @_;
	return $self->{home_table}->against ($team);
}

sub get_home_last_six_for {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{home_last_six_for};
}

sub get_home_last_six_against {
	my ($self, $team) = @_;
	return $self->{homes}->{$team}->{home_last_six_against};
}

sub get_home_played {
	my ($self, $team) = @_;
	return $self->{home_table}->played ($team);
}

# Aways

sub get_aways {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{aways};
}

sub get_full_aways {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{full_aways};
}

sub get_away_over_under {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{away_over_under};
}

sub get_away_points {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{points};
}

sub get_away_draws {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{draws};
}

sub get_away_goal_diff {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{goal_difference};
}

sub get_away_for {
	my ($self, $team) = @_;
	return $self->{away_table}->for ($team);
}

sub get_away_against {
	my ($self, $team) = @_;
	return $self->{away_table}->against ($team);
}

sub get_away_last_six_for {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{away_last_six_for};
}

sub get_away_last_six_against {
	my ($self, $team) = @_;
	return $self->{aways}->{$team}->{away_last_six_against};
}

sub get_away_played {
	my ($self, $team) = @_;
	return $self->{away_table}->played ($team);
}

# Last Six Games

sub get_last_six {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{last_six};
}

sub get_full_last_six {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{full_last_six};
}

sub get_last_six_points {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{points};
}

sub get_last_six_over_under {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{last_six_over_under};
}

sub get_last_six_goal_diff {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{goal_difference};
}

sub get_last_six_for {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{last_six_for};
}

sub get_last_six_against {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team}->{last_six_against};
}

# Get Most Recent

sub get_most_recent {
	my ($self, $team, $n) = @_;
	return $self->{teams}->{$team}->get_most_recent ($n);
}

# All team data (for form.pl)

sub get_team_home_data {
	my ($self, $team) = @_;
	return $self->{homes}->{$team};
}

sub get_team_away_data {
	my ($self, $team) = @_;
	return $self->{aways}->{$team};
}

sub get_team_last_six_data {
	my ($self, $team) = @_;
	return $self->{last_six}->{$team};
}

=pod

=head1 NAME

Roles::Team_Data.pm

=head1 SYNOPSIS

DSL implemented as a role used by Football::League.pm
to return data for each team in the league

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
