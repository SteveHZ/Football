package Football::Game_Predictions::Goal_Expect_Model;

use MyKeyword qw(ZEROGAMES);

use Moo;
use namespace::clean;

has 'leagues' 	=> (is => 'ro', default => sub { [] } );
has 'fixtures' 	=> (is => 'ro', default => sub { [] } );

sub BUILD {
#	my $self = shift;
#	my $end_msg = "\nEnable ZEROGAMES keyword in predict.pl and add '$team' to remove_teams array in fixtures2.pl\n";
#	$self->{home_die_msg} = "\n\n***ZERO HOME GAMES for $team".$end_msg;
#	$self->{away_die_msg} = "\n\n***ZERO AWAY GAMES for $team".$end_msg;
}

sub calc_goal_expects {
	my $self = shift;
	my $teams = {};

	for my $league (@{ $self->{leagues} }) {
		my $league_name = $league->{name};
		$league->{av_home_goals} = 1;
		$league->{av_away_goals} = 1;

		if (( my $total_games = _get_total_league_games ($league)) > 0 ) {
			$league->{av_home_goals} = _format ( _get_home_goals ($league) / $total_games );
			$league->{av_away_goals} = _format ( _get_away_goals ($league) / $total_games );
			for my $team ( @{ $league->{team_list} } ) {
				$teams->{$team} = {};
				$self->calculate_homes ($teams->{$team}, $league, $team);
				$self->calculate_aways ($teams->{$team}, $league, $team);
				$self->calculate_last_six ($teams->{$team}, $league, $team);
				$self->calculate_expects ($teams->{$team}, $league, $team);
			}
		}
	}
	return $teams;
}

sub sort_expect_data {
	my ($self, $sort_by) = @_;
	return [
		sort {
			abs $b->{$sort_by}  <=> abs $a->{$sort_by}
		} @{ $self->{fixtures} }
	];
}

sub grep_goal_diffs {
	my $self = shift;
	return [
		sort {
			abs $b->{home_away_goal_diff} <=> $a->{home_away_goal_diff}
		} grep {
			abs $_->{home_away_goal_diff} > 2 or
			abs $_->{last_six_goal_diff}  > 2
		} @{ $self->{fixtures} }
	];
}

sub calculate_homes {
	my ($self, $team_hash, $league, $team) = @_;
	my $played = $league->{home_table}->played ($team);
#	die $self->{home_die_msg} if $played == 0;
	ZEROGAMES { $played = 1 if $played == 0 }

	$team_hash->{home_for} 			= $league->{home_table}->for ($team);
	$team_hash->{home_against} 		= $league->{home_table}->against ($team);
	$team_hash->{av_home_for} 		= _format ( $team_hash->{home_for} / $played );
	$team_hash->{av_home_against} 	= _format ( $team_hash->{home_against} / $played );
}

sub calculate_aways {
	my ($self, $team_hash, $league, $team) = @_;
	my $played = $league->{away_table}->played ($team);
#	die $self->{away_die_msg} if $played == 0;
	ZEROGAMES { $played = 1 if $played == 0 }

	$team_hash->{away_for} 			= $league->{away_table}->for ($team);
	$team_hash->{away_against} 		= $league->{away_table}->against ($team);
	$team_hash->{av_away_for} 		= _format ( $team_hash->{away_for} / $played );
	$team_hash->{av_away_against} 	= _format ( $team_hash->{away_against} / $played );
}

sub calculate_last_six {
	my ($self, $team_hash, $league, $team) = @_;

	$team_hash->{last_six_for} 			= $league->get_last_six_for ($team);
	$team_hash->{last_six_against} 		= $league->get_last_six_against ($team);
	$team_hash->{av_last_six_for} 		= $team_hash->{last_six_for} / 6;
	$team_hash->{av_last_six_against} 	= $team_hash->{last_six_against} / 6;
}

sub calculate_expects {
	my ($self, $team_hash, $league, $team) = @_;

	$team_hash->{expect_home_for} 		= _format ( $team_hash->{av_home_for} 		/ $league->{av_home_goals} );
	$team_hash->{expect_home_against}	= _format ( $team_hash->{av_home_against} 	/ $league->{av_away_goals} );
	$team_hash->{expect_away_for} 		= _format ( $team_hash->{av_away_for} 		/ $league->{av_away_goals} );
	$team_hash->{expect_away_against}	= _format ( $team_hash->{av_away_against} 	/ $league->{av_home_goals} );

	$team_hash->{expect_last_six_home_for} 		= _format ( $team_hash->{av_last_six_for} 		/ $league->{av_home_goals} );
	$team_hash->{expect_last_six_home_against} 	= _format ( $team_hash->{av_last_six_against} 	/ $league->{av_away_goals} );
	$team_hash->{expect_last_six_away_for} 		= _format ( $team_hash->{av_last_six_for} 		/ $league->{av_away_goals} );
	$team_hash->{expect_last_six_away_against} 	= _format ( $team_hash->{av_last_six_against} 	/ $league->{av_home_goals} );
}

sub calc_expected_scores {
	my ($self, $teams, $game) = @_;

	my $league = @{ $self->{leagues} }[ $game->{league_idx} ];
	my $home = $game->{home_team};
	my $away = $game->{away_team};

	$game->{home_goals} =	$teams->{$home}->{expect_home_for} *
							$teams->{$away}->{expect_away_against} *
							$league->{av_home_goals};
	$game->{away_goals} =	$teams->{$away}->{expect_away_for} *
							$teams->{$home}->{expect_home_against} *
							$league->{av_away_goals};
	$game->{expected_goal_diff} = $game->{home_goals} - $game->{away_goals};

	$game->{home_last_six} =	$teams->{$home}->{expect_last_six_home_for} *
								$teams->{$away}->{expect_last_six_away_against} *
								$league->{av_home_goals};
	$game->{away_last_six} =	$teams->{$away}->{expect_last_six_away_for} *
								$teams->{$home}->{expect_last_six_home_against} *
								$league->{av_away_goals};
	$game->{expected_goal_diff_last_six} = $game->{home_last_six} - $game->{away_last_six};
}

sub calc_goal_diffs {
	my ($self, $teams, $game) = @_;

	my $league = @{ $self->{leagues} }[ $game->{league_idx} ];
	my $home = $game->{home_team};
	my $away = $game->{away_team};

	my $home_gd = $league->get_home_goal_diff ($home);
	my $away_gd = $league->get_away_goal_diff ($away);

#	May be less than six games played at start of season
	$game->{home_goal_diff} = _get_average ($home_gd, $league->get_homes ($home));
	$game->{away_goal_diff} = _get_average ($away_gd, $league->get_aways ($away));
	$game->{home_away_goal_diff} = _format ( $game->{home_goal_diff} - $game->{away_goal_diff} );

	my $home_last_six_gd = $league->get_last_six_goal_diff ($home);
	my $away_last_six_gd = $league->get_last_six_goal_diff ($away);

#	May be less than six games played at start of season
	$game->{home_last_six_goal_diff} = _get_average ($home_last_six_gd, $league->get_last_six ($home));
	$game->{away_last_six_goal_diff} = _get_average ($away_last_six_gd, $league->get_last_six ($away));
	$game->{last_six_goal_diff} = _format ( $game->{home_last_six_goal_diff} - $game->{away_last_six_goal_diff} );
};

#	private methods

sub _get_average {
	my ($value, $list) = @_;
	my $elems = scalar @$list;
	return 0 if $elems == 0;
	return _format ( $value / $elems );
}

# wrapper for testing
sub get_average {
	my $self = shift;
	return _get_average @_;
}

sub _format {
	my $value = shift;
	return sprintf "%.02f", $value;
}

sub _get_home_goals {
	my $league = shift;
	my $total = 0;

	for my $team (@{ $league->{team_list} }) {
		$total += $league->home_for ($team);
	}
	return $total;
}

sub _get_away_goals {
	my $league = shift;
	my $total = 0;

	for my $team (@{ $league->{team_list} }) {
		$total += $league->away_for ($team);
	}
	return $total;
}

sub _get_total_league_games {
	my $league = shift;
	my $total = 0;

	for my $team (@{ $league->{team_list} }) {
		$total += $league->home_played ($team);
	}
	return $total;
}

=pod

=head1 NAME

Goal_Expect_Model.pm

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