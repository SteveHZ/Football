package Football::Over_Under_Model;

#	Football::Over_Under_Model.pm 21/12/17, 26/05/18
#	https://www.online-betting.me.uk/strategies/vincent.php
#	https://www.online-betting.me.uk/strategies/ben.php

use Moo;
use namespace::clean;

has 'leagues' => (is => 'ro');
has 'fixtures' => (is => 'ro');

sub do_home_away {
	my $self = shift;

	return [
		sort {
			$b->{home_away} <=> $a->{home_away}
			or $b->{last_six} <=> $a->{last_six}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

sub do_last_six {
	my $self = shift;

	return [
		sort {
			$b->{last_six} <=> $a->{last_six}
			or $b->{home_away} <=> $a->{home_away}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

sub do_over_under {
	my $self = shift;

	return [
		sort {
			$b->{under_2pt5} <=> $a->{under_2pt5}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

sub do_over_under_points {
	my $self = shift;

	return [
		sort {
			$b->{ou_points} <=> $a->{ou_points}
			or $a->{home_team} cmp $b->{home_team}
		} @{ $self->{fixtures} }
	];
}

sub do_ou_points {
	my ($self, $game) = @_;
	my $league_array = $self->{leagues};
	my $teams = @$league_array [ $game->{league_idx} ]->teams;

	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my ($home_results, $home_stats) = $teams->{$home}->get_most_recent (4);
	my ($away_results, $away_stats) = $teams->{$away}->get_most_recent (4);

	return _do_calcs ([ @$home_stats, @$away_stats ]);
}

sub _do_calcs {
	my $stats = shift;
	my $total = 0;

	for my $game (@$stats) {
		my ($for, $ag) = split '-', $game->{score};
		if (($for + $ag) > 2)	 	{ $total += 0.5 }
		else						{ $total -= 0.5 }

		if ($for > 0 && $ag > 0)	{ $total += 0.75 }
		else						{ $total -= 0.75 }
	}
	return $total;
}

#	wrapper for testing

sub do_calcs {
	my $self = shift;
	_do_calcs @_;
}

sub do_unders {
	my $self = shift;
	my @unders = ();

	for my $league ( @{ $self->{leagues} } ) {
		for my $team ( @{ $league->team_list } ) {
			my $games = $league->get_most_recent ($team, 4);
			push @unders, {
				league => $league->{name},
				team => $team,
				goals => _get_total_goals ($games),
			};
		}
	}
	return [
		sort {
			$a->{goals} <=> $b->{goals}
			or $a->{team} cmp $b->{team}
		} @unders
	];
}

sub _get_total_goals {
	my $games = shift;
	my $total = 0;
	for my $game (@$games) {
		my ($for, $ag) = split '-', $game->{score};
		$total += ($for + $ag);
	}
	return $total;
}

=pod

=head1 NAME

Over_Under_Model.pm

=head1 SYNOPSIS

Used by predict.pl
Called from Game_Prediction_Models package

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
