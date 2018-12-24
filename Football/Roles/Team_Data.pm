package Football::Roles::Team_Data;

use Moo::Role;
use namespace::clean;

#requires qw( homes aways last_six );

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

# Last Six

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

Role used by League.pm to return data
for each team in the league

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
