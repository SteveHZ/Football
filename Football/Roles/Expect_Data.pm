package Football::Roles::Expect_Data;

use Moo::Role;

# API for expect data

sub _format {
	return sprintf "%.02f", shift;
}

sub get_game_expect {
	my ($stats, $home_team) = @_;
	for my $game ($stats->{by_match}->@*) {
		if ($game->{home_team} eq $home_team) {
			return $game;
		}
	}
	die "\nTeam $home_team not found !!!";
}

sub get_home_goals {
	my ($self, $game) = @_;
	return _format ($game->{home_goals});
}

sub get_away_goals {
	my ($self, $game) = @_;
	return _format ($game->{away_goals});
}

sub get_home_last_six {
	my ($self, $game) = @_;
	return _format ($game->{home_last_six});
}

sub get_away_last_six {
	my ($self, $game) = @_;
	return _format ($game->{away_last_six});
}

sub get_expected_goal_diff {
	my ($self, $game) = @_;
	return _format ($game->{expected_goal_diff});
}

sub get_expected_goal_diff_last_six {
	my ($self, $game) = @_;
	return _format ($game->{expected_goal_diff_last_six});
}

=pod

=head1 NAME

Roles::Expect_Data.pm

=head1 SYNOPSIS

DSL implemented as a role used by Football::Model.pm
to return Goal Expect data for each team in the league

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

