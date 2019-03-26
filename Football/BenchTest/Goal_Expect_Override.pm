package Football::BenchTest::Goal_Expect_Override;

#use Data::Dumper;
use Moo;
use namespace::clean;

extends 'Football::Goal_Expect_Model';

#after 'BUILD' => sub {
#    my $self = shift;
#    $self->{model}->{fixtures} = $self->{fixtures};
#    $self->{model}->{leagues} = $self->{leagues};
#};

sub calc_expected_scores {
    my ($self, $teams, $game) = @_;

	my $league = @{ $self->{leagues} }[ $game->{league_idx} ];
	my $home = $game->{home_team};
	my $away = $game->{away_team};

	$game->{home_goals} =	$teams->{$home}->{expect_home_for} *
							$teams->{$away}->{expect_away_against} *
							sqrt ( $league->{av_home_goals} );
	$game->{away_goals} =	$teams->{$away}->{expect_away_for} *
							$teams->{$home}->{expect_home_against} *
							sqrt ( $league->{av_away_goals} );
	$game->{expected_goal_diff} = $game->{home_goals} - $game->{away_goals};

	$game->{home_last_six} =	$teams->{$home}->{expect_last_six_home_for} *
								$teams->{$away}->{expect_last_six_away_against} *
								sqrt ( $league->{av_home_goals} );
	$game->{away_last_six} =	$teams->{$away}->{expect_last_six_away_for} *
								$teams->{$home}->{expect_last_six_home_against} *
								sqrt ( $league->{av_away_goals} );
	$game->{expected_goal_diff_last_six} = $game->{home_last_six} - $game->{away_last_six};
}

1;
