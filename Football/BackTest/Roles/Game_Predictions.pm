package Football::BackTest::Roles::Game_Predictions;

use Football::Game_Predictions::Goal_Expect_Model;
use Football::Game_Predictions::Match_Odds;

use Moo::Role;
use namespace::clean;

sub calc_goal_expect {
    my ($self, $game, $league) = @_;

    my $expect = Football::Game_Predictions::Goal_Expect_Model->new (
		fixtures => [ $game ],
		leagues => [ $league ],
	);
	my $teams = $expect->calc_goal_expects ();
	$expect->calc_expected_scores ($teams, $game);
	$expect->calc_goal_diffs ($teams, $game);
	return $teams;
}

sub calc_match_odds {
	my ($self, $game) = @_;

    my $odds = Football::Game_Predictions::Match_Odds->new ();
#    my $odds = Football::Game_Predictions::Match_Odds->new (weighted => 1);
    return $self->get_odds ($odds, $game);
}

# temporary sub to allow hash to be returned from Match_Odds version
sub get_odds {
	my ($self, $odds, $game) = @_;
#	return $odds->calc_odds ($game->{home_last_six}, $game->{away_last_six});
	return $odds->calc_odds ($game->{home_goals}, $game->{away_goals});
}

=pod

=head1 NAME

Football/BenchTest/Adapter/Game_Prediction_Models.pm

=head1 SYNOPSIS

Used by backtest.pl to simplify calling the Game_Prediction models module for a single game

=head1 DESCRIPTION

Instead of
my $predict_model = Football::Game_Prediction_Models->new (
    fixtures => [ $game ],
    leagues  => [ $league ],
);

Much simpler to write
my $predict_model = Football::BenchTest::Adapter::Game_Prediction_Models->new (
    game    => $game,
    league  => $league,
);

game and league will convert to fixtures => [$game] and leagues => [$league] behind the scenes

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
