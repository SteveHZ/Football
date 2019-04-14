package Football::League;

#	Football::League.pm 23/02/16, Mouse version 04/05/16
#	Moo version 01/10/16
# 	v 1.1 05/05/17

use Football::Table;
use Football::HomeTable;
use Football::AwayTable;

use Football::Team;
use Football::Roles::Team_Data;
use MyKeyword qw(DEVELOPMENT);

use Moo;
use namespace::clean;

#	constructor arguments
has 'name' => ( is => 'ro' );
has 'games' => ( is => 'ro' );
has 'team_list' => ( is => 'ro' );
has 'auto_build' => ( is => 'ro', default => 1);	# for backtest.#!/usr/bin/env perl

#	other object data
has 'teams' => ( is => 'ro', default => sub { {} }, );
has 'table' => (is => 'ro', default => sub { {} }, handles => [ qw( position played won lost drawn for against points ) ]);
has 'home_table' => ( is => 'ro', default => sub { {} }, handles => [ qw( home_position home_played home_won home_lost home_drawn home_for home_against home_points ) ]);
has 'away_table' => ( is => 'ro', default => sub { {} }, handles => [ qw( away_position away_played away_won away_lost away _drawn away_for away_against away_points ) ]);

has 'homes' => ( is => 'ro', default => sub { {} }, );
has 'aways' => ( is => 'ro', default => sub { {} }, );
has 'last_six' => ( is => 'ro', default => sub { {} }, );

with 'Football::Roles::Team_Data';

sub BUILD {
	my $self = shift;
	$self->{points} = { W => 3, D => 1, L => 0, };
	$self->build_teams ();
}

sub get_table {
	my $self = shift;
	return $self->{table}->table;
}

sub create_new_table {
	my $self = shift;
	return Football::Table->new (
		teams => $self->{team_list}
	);
}

sub create_new_home_table {
	my $self = shift;
	return Football::HomeTable->new (
		teams => $self->{team_list}
	);
}

sub create_new_away_table {
	my $self = shift;
	return Football::AwayTable->new (
		teams => $self->{team_list}
	);
}

sub build_teams {
	my $self = shift;

	$self->{table} = $self->create_new_table ();
	$self->{home_table} = $self->create_new_home_table ();
	$self->{away_table} = $self->create_new_away_table ();

	for my $team (@ {$self->{team_list} } ) {
		$self->{teams}->{$team} = Football::Team->new ();
	}

	if ($self->{auto_build}) {
		for my $game ( @{ $self->{games} } ) {
			$self->update_teams ($self->{teams}, $game);
			$self->update_tables ($game);
		}
		$self->sort_tables ();
	}
}

sub update_tables {
	my ($self, $game) = @_;
	$self->{table}->update ($game);
	$self->{home_table}->update ($game);
	$self->{away_table}->update ($game);
}

sub sort_tables {
	my $self = shift;
	$self->{table}->sort_table ();
	$self->{home_table}->sort_table ();
	$self->{away_table}->sort_table ();
}

sub update_teams {
	my ($self, $teams, $game) = @_;

	my $home_team = $game->{home_team};
	my $away_team = $game->{away_team};
	my ($home_result, $away_result) = get_result ($game->{home_score}, $game->{away_score});

	DEVELOPMENT {
		print "\n$home_team v $away_team";
	}
	$teams->{$home_team}->add ( update_home ($game, $home_result));
	$teams->{$away_team}->add ( update_away ($game, $away_result));
}

sub get_result {
	my ($home, $away) = @_;
	return ('W','L') if $home > $away;
	return ('L','W') if $home < $away;
	return ('D','D');
}

sub update_home {
	my ($game, $home_result) = @_;
	return {
		date => $game->{date},
		opponent => $game->{away_team},
		home_away => 'H',
		result => $home_result,
		score => $game->{home_score}.'-'.$game->{away_score},
	};
}

sub update_away {
	my ($game, $away_result) = @_;
	return {
		date => $game->{date},
		opponent => $game->{home_team},
		home_away => 'A',
		result => $away_result,
		score => $game->{away_score}.'-'.$game->{home_score}
	};
}

sub do_homes {
	my ($self, $teams) = @_;
	my $list = {};
	for my $team (@{ $self->{team_list} }) {
		my ( $homes, $full_homes ) = $teams->{$team}->get_homes ();
		$list->{$team} = {
 			name => $team,
			homes => $homes,
			full_homes => $full_homes,
			points => $self->_get_points ($homes),
			draws => $self->_get_draws ($homes),
			goal_difference => $self->{table}->calc_goal_difference ($full_homes),
			home_over_under => $self->_get_over_under ($full_homes),
		};
	}
	return $list;
}

sub do_aways {
	my ($self, $teams) = @_;
	my $list = {};

	for my $team (@{ $self->{team_list} }) {
		my ( $aways, $full_aways ) = $teams->{$team}->get_aways ();
		$list->{$team} = {
 			name => $team,
			aways => $aways,
			full_aways => $full_aways,
			points => $self->_get_points ($aways),
			draws => $self->_get_draws ($aways),
			goal_difference => $self->{table}->calc_goal_difference ($full_aways),
			away_over_under => $self->_get_over_under ($full_aways),
		};
	}
	return $list;
}

sub do_last_six {
	my ($self, $teams) = @_;
	my $list = {};

	for my $team (@{ $self->{team_list} }) {
		my ( $last_six, $full_last_six ) = $teams->{$team}->most_recent ();
		my ($last_six_for, $last_six_against) = $self->_get_last_six_scores ($full_last_six);
		$list->{$team} = {
 			name => $team,
			last_six => $last_six,
			full_last_six => $full_last_six,
			points => $self->_get_points ($last_six),
			draws => $self->_get_draws ($last_six),
			goal_difference => $self->{table}->calc_goal_difference ($full_last_six),
			last_six_for => $last_six_for,
			last_six_against => $last_six_against,
			last_six_over_under => $self->_get_over_under ($full_last_six),
		};
	}
	return $list;
}

#	private methods

sub _get_points {
	my ($self, $stats) = @_;
	my $total = 0;

	for my $game (@$stats) {
		$total += $self->{points}->{$game};
	}
	return $total;
}

sub _get_draws {
	my ($self, $stats) = @_;
	my $total = 0;

	for my $game (@$stats) {
		$total ++ if $game eq 'D';
	}
	return $total;
}

sub _get_last_six_scores {
	my ($self, $stats) = @_;
	my ($for, $against) = (0,0);

	for my $game (@$stats) {
		my ($game_for, $game_against) = split ('-', $game->{score});
		$for += $game_for;
		$against += $game_against;
	}
	return ($for, $against);
}

sub _get_over_under {
	my ($self, $stats) = @_;
	my $over = 0;

	for my $game (@$stats) {
		my ($game_for, $game_against) = split ('-', $game->{score});
		$over ++ if $game_for + $game_against > 2;
	}
	return $over;
}

=head
sub get_home_table {
	my $self = shift;
	return $self->{home_table};
}

sub get_away_table {
	my $self = shift;
	return $self->{away_table};
}

sub build_teams {
	my $self = shift;

	$self->{table} = $self->create_new_table ();

	for my $team (@ {$self->{team_list} } ) {
		$self->{teams}->{$team} = Football::Team->new ();
	}

	if ($self->{auto_build}) {
		for my $game ( @{ $self->{games} } ) {
			$self->update_teams ($self->{teams}, $game);
			$self->{table}->update ($game);
		}
		$self->{table}->sort_table ();
	}
}

sub get_home_table {
	my ($self, $games) = @_;
	my $table = $self->create_new_home_table ();

	for my $game (@$games) {
		$table->update ($game);
	}
#	die "No home games played" if $table->check_for_zero_games ();
	$table->sort_table ();
	return $table;
}

sub get_away_table {
	my ($self, $games) = @_;
	my $table = $self->create_new_away_table ();

	for my $game (@$games) {
		$table->update ($game);
	}
#	die "No away games played" if $table->check_for_zero_games ();
	$table->sort_table ();
	return $table;
}
=cut
=pod

=head1 NAME

League.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
