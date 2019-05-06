package Football::BenchTest::Goal_Expect_Override;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::Goal_Expect_Model';

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

=pod

=head1 NAME

Football/BenchTest/Goal_Expect_Model_Override.pm;

=head1 SYNOPSIS

use Football::BenchTest::Goal_Expect_Override;
my $model = Football::BenchTest::Goal_Expect_Model_Override->new();

=head1 DESCRIPTION

Used by backtest.pl to override calc_expected_scores method in Goal_Expect_Model.

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
