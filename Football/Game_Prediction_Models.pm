package Football::Game_Prediction_Models;

use Football::Goal_Expect_Model;
use Football::Match_Odds;
use Football::Skellam_Dist_Model;
use Football::Over_Under_Model;

use Moo;
use namespace::clean;

sub calc_goal_expect {
	my ($self, $fixtures, $leagues) = @_;
	my $sorted = {};

	my $expect = Football::Goal_Expect_Model->new (
		fixtures => $fixtures,
		leagues => $leagues,
	);

	my $teams = $expect->calc_goal_expects ();
	
	for my $game (@$fixtures) {
		$expect->calc_expected_scores ($teams, $game);
		$expect->calc_goal_diffs ($teams, $game);
	}

	$sorted->{expect}    = $expect->sort_expect_data ('expected_goal_diff'); 
	$sorted->{home_away} = $expect->sort_expect_data ('home_away_goal_diff');
	$sorted->{last_six}  = $expect->sort_expect_data ('last_six_goal_diff');
	$sorted->{grepped}   = $expect->grep_goal_diffs ();

	return ($teams, $sorted);
}

sub calc_match_odds {
	my ($self, $fixtures) = @_;

	my $odds = Football::Match_Odds->new ();
	
	for my $game (@$fixtures) {
		$odds->calc ($game->{home_goals}, $game->{away_goals});

		$game->{home_win} = $odds->home_win_odds ();
		$game->{away_win} = $odds->away_win_odds ();
		$game->{draw} = $odds->draw_odds ();
		$game->{both_sides_yes} = $odds->both_sides_yes_odds ();
		$game->{both_sides_no} = $odds->both_sides_no_odds ();
		$game->{under_2pt5} = $odds->under_2pt5_odds ();
		$game->{over_2pt5} = $odds->over_2pt5_odds ();
	}
	return $odds->schwartz_sort ($fixtures);
}

sub calc_skellam_dist {
	my ($self, $fixtures) = @_;
	
	my $skellam = Football::Skellam_Dist_Model->new ();
	
	for my $game (@$fixtures) {
		$game->{skellam} = $skellam->calc ($game->{home_goals}, $game->{away_goals});
	}
	return $skellam->schwartz_sort ($fixtures);
}

sub calc_over_under {
	my ($self, $fixtures, $leagues) = @_;

	my $sorted = {};
	my $over_under = Football::Over_Under_Model->new (
		fixtures => $fixtures,
		leagues => $leagues,
	);
	
	$sorted->{ou_home_away} = $over_under->do_home_away ();
	$sorted->{ou_last_six} = $over_under->do_last_six ();
	$sorted->{ou_odds} = $over_under->do_over_under ();
	$sorted->{ou_points} = $over_under->do_over_under_points ();
	return $sorted;
}

=pod

=head1 NAME

Game_Prediction_Models.pm

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
