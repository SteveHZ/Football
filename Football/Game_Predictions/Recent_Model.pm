package Football::Game_Predictions::Recent_Model;

use Moo;
use namespace::clean;

extends 'Football::Game_Predictions::Model';

sub sort_expect_data {
	my $self = shift;
	die "No model defined !!" unless defined $self->{expect_model};
	return $self->{expect_model}->sort_expect_data ('expected_goal_diff_last_six');
}

sub get_odds {
	my ($self, $odds, $game) = @_;
	return	$odds->calc_odds ($game->{home_last_six}, $game->{away_last_six});
}

1;
