package Football::Goal_Expect_Model;

use Moo;
use namespace::clean;

has 'leagues' => (is => 'ro', default => sub { [] });
has 'fixtures' => (is => 'ro', default => sub { [] } );

sub calc_goal_expects {
	my $self = shift;
	my $teams = {};

	for my $league (@{ $self->{leagues} }) {
		my $league_name = $league->{title};
		$league->{av_home_goals} = 1;
		$league->{av_away_goals} = 1;

		if (( my $total_games = get_total_league_games ($league)) > 0 ) {
			$league->{av_home_goals} = sprintf "%0.2f", get_home_goals ($league) / $total_games;
			$league->{av_away_goals} = sprintf "%0.2f", get_away_goals ($league) / $total_games;
			for my $team ( @{ $league->{team_list} } ) {
				$self->calculate_homes ($teams, $league, $team);
				$self->calculate_aways ($teams, $league, $team);
				$self->calculate_last_six ($teams, $league, $team);
				$self->calculate_expects ($teams, $league, $team);
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
		grep {
			abs $_->{home_away_goal_diff} > 2 or
			abs $_->{last_six_goal_diff}  > 2
		} @{ $self->{fixtures} }
	];
}

sub calculate_homes {
	my ($self, $teams, $league, $team) = @_;
	my $played = $league->{home_table}->played ($team);
	
	$teams->{$team}->{home_for} = $league->{home_table}->for($team);
	$teams->{$team}->{home_against} = $league->{home_table}->against($team);
	$teams->{$team}->{av_home_for} = sprintf "%0.2f", $teams->{$team}->{home_for} / $played;
	$teams->{$team}->{av_home_against} = sprintf "%0.2f", $teams->{$team}->{home_against} / $played;
}

sub calculate_aways {
	my ($self, $teams, $league, $team) = @_;
	my $played = $league->{away_table}->played ($team);

	$teams->{$team}->{away_for} = $league->{away_table}->for($team);
	$teams->{$team}->{away_against} = $league->{away_table}->against($team);
	$teams->{$team}->{av_away_for} = sprintf "%0.2f", $teams->{$team}->{away_for} / $played;
	$teams->{$team}->{av_away_against} = sprintf "%0.2f", $teams->{$team}->{away_against} / $played;
}

sub calculate_last_six {
	my ($self, $teams, $league, $team) = @_;

	$teams->{$team}->{last_six_for} = $league->{last_six}->{$team}->{last_six_for};
	$teams->{$team}->{last_six_against} = $league->{last_six}->{$team}->{last_six_against};
	$teams->{$team}->{av_last_six_for} = $teams->{$team}->{last_six_for} / 6;
	$teams->{$team}->{av_last_six_against} = $teams->{$team}->{last_six_against} / 6;
}

sub calculate_expects {
	my ($self, $teams, $league, $team) = @_;
		
	$teams->{$team}->{expect_home_for} = sprintf "%0.2f", $teams->{$team}->{av_home_for} / $league->{av_home_goals};
	$teams->{$team}->{expect_home_against} = sprintf "%0.2f", $teams->{$team}->{av_home_against} / $league->{av_away_goals};
	$teams->{$team}->{expect_away_for} = sprintf "%0.2f", $teams->{$team}->{av_away_for} / $league->{av_away_goals};
	$teams->{$team}->{expect_away_against} = sprintf "%0.2f", $teams->{$team}->{av_away_against} / $league->{av_home_goals};

	$teams->{$team}->{expect_last_six_home_for} = sprintf "%0.2f", $teams->{$team}->{av_last_six_for}
		/ $league->{av_home_goals};
	$teams->{$team}->{expect_last_six_home_against} = sprintf "%0.2f", $teams->{$team}->{av_last_six_against}
		/ $league->{av_away_goals};
	$teams->{$team}->{expect_last_six_away_for} = sprintf "%0.2f", $teams->{$team}->{av_last_six_for}
		/ $league->{av_away_goals};
	$teams->{$team}->{expect_last_six_away_against} = sprintf "%0.2f", $teams->{$team}->{av_last_six_against}
		/ $league->{av_home_goals};
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

	my $home_gd = $league->{homes}->{$home}->{goal_difference};
	my $away_gd = $league->{aways}->{$away}->{goal_difference};

	$game->{home_goal_diff} = get_average ($home_gd, $league->{homes}->{$home}, "homes");
	$game->{away_goal_diff} = get_average ($away_gd, $league->{aways}->{$away}, "aways");
	$game->{home_away_goal_diff} = sprintf ("%0.2f", $game->{home_goal_diff} - $game->{away_goal_diff} );

	my $home_last_six_gd = $league->{last_six}->{$home}->{goal_difference};
	my $away_last_six_gd = $league->{last_six}->{$away}->{goal_difference};
	
	$game->{home_last_six_goal_diff} = get_average ($home_last_six_gd, $league->{last_six}->{$home}, "last_six" );
	$game->{away_last_six_goal_diff} = get_average ($away_last_six_gd, $league->{last_six}->{$away}, "last_six" );
	$game->{last_six_goal_diff} = sprintf ("%0.2f", $game->{home_last_six_goal_diff} - $game->{away_last_six_goal_diff} );
};

sub get_average {
	my ($value, $list, $home_away) = @_;
	return 0 if scalar ( @{$list->{$home_away}} ) == 0;
	return sprintf ("%.02f", $value / scalar ( @{$list->{$home_away}} ));
}

sub get_home_goals {
	my $league = shift;
	my $total = 0;

	for my $team (@{ $league->{team_list} }) {
		$total += $league->{home_table}->for ($team);
	}
	return $total;
}

sub get_away_goals {
	my $league = shift;
	my $total = 0;

	for my $team (@{ $league->{team_list} }) {
		$total += $league->{away_table}->for ($team);
	}
	return $total;
}

sub get_total_league_games {
	my $league = shift;
	my $total = 0;

	for my $team (@{ $league->{team_list} }) {
		$total += $league->{home_table}->played ($team);
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
