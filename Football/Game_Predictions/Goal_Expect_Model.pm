package Football::Game_Predictions::Goal_Expect_Model;

use MyKeyword qw(ZEROGAMES);
use Moo;
use namespace::clean;

has 'leagues' 	=> (is => 'ro', default => sub { [] } );
has 'fixtures' 	=> (is => 'ro', default => sub { [] } );

sub BUILD {
	my $self = shift;
	$self->{end_msg} = "\nEnable ZEROGAMES pragma in predict.pl and add team name to remove_teams array in fixtures2.pl\nAlso amend calculate_homes and calculate_aways subs in Goal_Expect_Model !!\n";
}

#	private methods

my sub _format {
	return sprintf "%.02f", shift;
}

my sub _get_average {
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

my sub _get_home_goals {
	my $league = shift;
	my $total = 0;

	for my $team ( $league->{team_list}->@* ) {
		$total += $league->home_for ($team);
	}
	return _format ($total);
}

my sub _get_away_goals {
	my $league = shift;
	my $total = 0;

	for my $team ( $league->{team_list}->@* ) {
		$total += $league->away_for ($team);
	}
	return _format ($total);
}

my sub _get_total_league_games {
	my $league = shift;
	my $total = 0;

	for my $team ( $league->{team_list}->@* ) {
		$total += $league->home_played ($team);
	}
	return $total;
}

#	public methods

sub calc_goal_expects {
	my $self = shift;
	my $teams = {};

	for my $league ( $self->{leagues}->@* ) {
		$league->{av_home_goals} = 1;
		$league->{av_away_goals} = 1;

		if (( my $total_games = _get_total_league_games ($league)) > 0 ) {
			$league->{av_home_goals} = _get_home_goals ($league) / $total_games;
			$league->{av_away_goals} = _get_away_goals ($league) / $total_games;
			for my $team ( $league->{team_list}->@* ) {
				$teams->{$team} = $self->calc_team_expects ($league, $team);
			}
		}
	}
	return $teams;
}

sub calc_team_expects {
	my ($self, $league, $team) = @_;
	my $hash = {};

	$self->calculate_homes ($hash, $league, $team);
	$self->calculate_aways ($hash, $league, $team);
	$self->calculate_last_six ($hash, $league, $team);
	$self->calculate_expects ($hash, $league, $team);
	return $hash;
}

sub sort_expect_data {
	my ($self, $sort_by) = @_;
	return [
		sort {
			abs $b->{$sort_by}  <=> abs $a->{$sort_by}
		} $self->{fixtures}->@*
	];
}

sub calculate_homes {
	my ($self, $team_hash, $league, $team) = @_;
	my $played = $league->get_home_played ($team);

	die "\n\n***ZERO HOME GAMES for $team".$self->{end_msg} if $played == 0;
#	ZEROGAMES { if ($played == 0) {
#		$played = 1; print "\nZero home games : $team"; <STDIN>;
#	} }

	$team_hash->{home_for} 			= $league->get_home_for ($team);
	$team_hash->{home_against} 		= $league->get_home_against ($team);
	$team_hash->{av_home_for} 		= _format ( $team_hash->{home_for} / $played );
	$team_hash->{av_home_against} 	= _format ( $team_hash->{home_against} / $played );
}

sub calculate_aways {
	my ($self, $team_hash, $league, $team) = @_;
	my $played = $league->get_away_played ($team);

	die "\n\n***ZERO AWAY GAMES for $team".$self->{end_msg} if $played == 0;
#	ZEROGAMES { if ($played == 0) {
#		 $played = 1; print "\nZero away games : $team"; <STDIN>;
#	 } }

	$team_hash->{away_for} 			= $league->get_away_for ($team);
	$team_hash->{away_against} 		= $league->get_away_against ($team);
	$team_hash->{av_away_for} 		= _format ( $team_hash->{away_for} / $played );
	$team_hash->{av_away_against} 	= _format ( $team_hash->{away_against} / $played );
}

sub calculate_last_six {
	my ($self, $team_hash, $league, $team) = @_;

	my $home_last_six_for = $league->get_home_last_six_for ($team);
	my $home_last_six_against = $league->get_home_last_six_against ($team);
	my $away_last_six_for = $league->get_away_last_six_for ($team);
	my $away_last_six_against = $league->get_away_last_six_against ($team);

	my $homes = $league->get_homes ($team);
	my $aways = $league->get_aways ($team);
	$team_hash->{av_home_last_six_for} = _get_average ($home_last_six_for, $homes);
	$team_hash->{av_home_last_six_against} = _get_average ($home_last_six_against, $homes);
	$team_hash->{av_away_last_six_for} = _get_average ($away_last_six_for, $aways);
	$team_hash->{av_away_last_six_against} = _get_average ($home_last_six_against, $aways);
}

sub calculate_expects {
	my ($self, $team_hash, $league, $team) = @_;

	$team_hash->{expect_home_for} 		= _format ( $team_hash->{av_home_for} 		/ $league->{av_home_goals} );
	$team_hash->{expect_home_against}	= _format ( $team_hash->{av_home_against} 	/ $league->{av_away_goals} );
	$team_hash->{expect_away_for} 		= _format ( $team_hash->{av_away_for} 		/ $league->{av_away_goals} );
	$team_hash->{expect_away_against}	= _format ( $team_hash->{av_away_against} 	/ $league->{av_home_goals} );

	$team_hash->{expect_last_six_home_for} 		= _format ( $team_hash->{av_home_last_six_for} 		/ $league->{av_home_goals} );
	$team_hash->{expect_last_six_home_against} 	= _format ( $team_hash->{av_home_last_six_against} 	/ $league->{av_away_goals} );
	$team_hash->{expect_last_six_away_for} 		= _format ( $team_hash->{av_away_last_six_for} 		/ $league->{av_away_goals} );
	$team_hash->{expect_last_six_away_against} 	= _format ( $team_hash->{av_away_last_six_against} 	/ $league->{av_home_goals} );
}

sub calc_expected_scores {
	my ($self, $teams, $game) = @_;

	my $league = $self->{leagues}->[ $game->{league_idx} ];
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

	my $league = $self->{leagues}->[ $game->{league_idx} ];
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
