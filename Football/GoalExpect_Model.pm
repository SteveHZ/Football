package Football::GoalExpect_Model;

use Football::Match_Odds;

use Moo;
use namespace::clean;

sub update {
	my ($self, $leagues, $fixtures) = @_;

	my $teams = {};
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $total_games = get_total_league_games ($league);
		$league->{av_home_goals} = sprintf "%0.2f", get_home_goals ($league) / $total_games;
		$league->{av_away_goals} = sprintf "%0.2f", get_away_goals ($league) / $total_games;

		print "\n\nTotal $league_name home goals : $league->{av_home_goals}";
		print "\nTotal $league_name away goals : $league->{av_away_goals}";

		for my $team ( @{ $league->{team_list} } ) {
			$self->calculate_homes ($league, $teams, $team);
			$self->calculate_aways ($league, $teams, $team);
			$self->calculate_last_six ($league, $teams, $team);
			$self->calculate_expects ($league, $teams, $team);
		}
	}

	for my $game (@$fixtures) {
		$self->calc_expected_scores ($leagues, $teams, $game);
		$self->calc_goal_diffs ($leagues, $teams, $game);
	}
	
	my @sorted = sort { abs $b->{expected_goal_diff} <=> abs $a->{expected_goal_diff} } @$fixtures; 
	return ($teams, \@sorted);
}

sub calc_goal_stats {
	my ($self, $fixtures) = @_;

	my $odds = Football::Match_Odds->new ();
	
	for my $game (@$fixtures) {
		$odds->calc ($game->{home_goals}, $game->{away_goals});
		
		$game->{home_win} = $odds->home_win_odds ();
		$game->{away_win} = $odds->away_win_odds ();
		$game->{draw} = $odds->draw_odds ();
		$game->{both_sides_yes} = $odds->both_sides_yes_odds ();
		$game->{both_sides_no} = $odds->both_sides_no_odds ();
		$game->{under_two_half} = $odds->under_two_half_odds ();
		$game->{over_two_half} = $odds->over_two_half_odds ();
	}
}

sub calculate_homes {
	my ($self, $league, $teams, $team) = @_;
	
	$teams->{$team}->{home_for} = $league->{home_table}->for($team);
	$teams->{$team}->{home_against} = $league->{home_table}->against($team);
	$teams->{$team}->{av_home_for} = sprintf "%0.2f", $teams->{$team}->{home_for} / $league->{home_table}->played ($team);
	$teams->{$team}->{av_home_against} = sprintf "%0.2f", $teams->{$team}->{home_against} / $league->{home_table}->played ($team);
}

sub calculate_aways {
	my ($self, $league, $teams, $team) = @_;

	$teams->{$team}->{away_for} = $league->{away_table}->for($team);
	$teams->{$team}->{away_against} = $league->{away_table}->against($team);
	$teams->{$team}->{av_away_for} = sprintf "%0.2f", $teams->{$team}->{away_for} / $league->{away_table}->played ($team);
	$teams->{$team}->{av_away_against} = sprintf "%0.2f", $teams->{$team}->{away_against} / $league->{away_table}->played ($team);
}

sub calculate_last_six {
	my ($self, $league, $teams, $team) = @_;

	$teams->{$team}->{last_six_for} = $league->{last_six}->{$team}->{last_six_for};
	$teams->{$team}->{last_six_against} = $league->{last_six}->{$team}->{last_six_against};
	$teams->{$team}->{av_last_six_for} = $teams->{$team}->{last_six_for} / 6;
	$teams->{$team}->{av_last_six_against} = $teams->{$team}->{last_six_against} / 6;
}

sub calculate_expects {
	my ($self, $league, $teams, $team) = @_;
		
	$teams->{$team}->{expect_home_for} = sprintf "%0.2f", $teams->{$team}->{av_home_for} / $league->{av_home_goals};
	$teams->{$team}->{expect_home_against} = sprintf "%0.2f", $teams->{$team}->{av_home_against} / $league->{av_away_goals};
	$teams->{$team}->{expect_away_for} = sprintf "%0.2f", $teams->{$team}->{av_away_for} / $league->{av_away_goals};
	$teams->{$team}->{expect_away_against} = sprintf "%0.2f", $teams->{$team}->{av_away_against} / $league->{av_home_goals};

	$teams->{$team}->{expect_last_six_home_for} = sprintf "%0.2f", $teams->{$team}->{av_last_six_for} / $league->{av_home_goals};
	$teams->{$team}->{expect_last_six_home_against} = sprintf "%0.2f", $teams->{$team}->{av_last_six_against} / $league->{av_away_goals};
	$teams->{$team}->{expect_last_six_away_for} = sprintf "%0.2f", $teams->{$team}->{av_last_six_for} / $league->{av_away_goals};
	$teams->{$team}->{expect_last_six_away_against} = sprintf "%0.2f", $teams->{$team}->{av_last_six_against} / $league->{av_home_goals};
}

sub calc_expected_scores {
	my ($self, $leagues, $teams, $game) = @_;
	
	my $league = @$leagues[ $game->{league_idx} ];
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
	my ($self, $leagues, $teams, $game) = @_;
	
	my $league = @$leagues[ $game->{league_idx} ];
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

1;
