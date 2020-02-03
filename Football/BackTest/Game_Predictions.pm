package Football::BackTest::Game_Predictions;

use List::Util qw(any);
use Football::Game_Predictions::Goal_Expect_Model;
use Football::Game_Predictions::Match_Odds;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::Model';

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

    my $odds = Football::Game_Predictions::Match_Odds->new (weighted => 1);
    return $odds->calc_odds ($game)
}

#has 'game' => (is => 'ro', required => 1);
#has 'league' => (is => 'ro', required => 1);

#sub BUILD {
#    my $self = shift;
#    $self->{fixtures}    = [ $self->{game} ];
#    $self->{leagues}     = [ $self->{league} ];
#
#    my @expects_args = qw( expect_model over_under_model );
#	for my $name (keys %{$self->{models}} ) {
#        if (any { $_ eq $name} @expects_args) {
#       		$self->{models}->{$name}->{fixtures} = $self->{fixtures};
#    		$self->{models}->{$name}->{leagues} = $self->{leagues};
#        }
#    }
#}

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
