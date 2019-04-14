package Football::Game_Prediction_Models;

use Football::Goal_Expect_Model;
use Football::Match_Odds;
use Football::Skellam_Dist_Model;
use Football::Over_Under_Model;
use Football::Globals qw( $default_stats_size );

use Moo;
use namespace::clean;

#	models can be defined by Football::BenchTest::Adapter::Game_Prediction_Models
has 'models' => (is => 'ro', default => sub { {} });
has 'fixtures' => (is => 'ro', default => sub { [] }, required => 1);
has 'leagues' => (is => 'ro', default => sub { [] }, required => 1);

sub calc_goal_expect {
	my $self = shift;
	my $sorted = {};

	$self->{models}->{expect_model} = Football::Goal_Expect_Model->new (
		fixtures => $self->{fixtures},
		leagues => $self->{leagues},
	) unless defined $self->{models}->{expect_model};
	my $expect = $self->{models}->{expect_model};

	my $teams = $expect->calc_goal_expects ();
	for my $game (@{ $self->{fixtures} } ) {
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
	my $self = shift;

	$self->{models}->{odds_model} = Football::Match_Odds->new ()
		unless defined $self->{models}->{odds_model};
	my $odds = $self->{models}->{odds_model};

	for my $game (@{ $self->{fixtures} } ) {
		$odds->calc ($game->{home_goals}, $game->{away_goals});

		$game->{home_win} = $odds->home_win_odds ();
		$game->{away_win} = $odds->away_win_odds ();
		$game->{draw} = $odds->draw_odds ();
		$game->{both_sides_yes} = $odds->both_sides_yes_odds ();
		$game->{both_sides_no} = $odds->both_sides_no_odds ();
		$game->{under_2pt5} = $odds->under_2pt5_odds ();
		$game->{over_2pt5} = $odds->over_2pt5_odds ();
	}
	return $odds->schwartz_sort ($self->{fixtures});
}

sub calc_skellam_dist {
	my $self = shift;

	$self->{models}->{skellam_model} = Football::Skellam_Dist_Model->new ()
		unless defined $self->{models}->{skellam_model};
	my $skellam = $self->{models}->{skellam_model};

	for my $game (@{ $self->{fixtures} } ) {
		$game->{skellam} = $skellam->calc ($game->{home_goals}, $game->{away_goals});
	}
	return $skellam->schwartz_sort ($self->{fixtures});
}

sub calc_over_under {
	my $self = shift;
	my $stat_size = $default_stats_size * 2;

	my $sorted = {};
	$self->{models}->{over_under_model} = Football::Over_Under_Model->new (
		fixtures => $self->{fixtures},
		leagues => $self->{leagues},
	) unless defined $self->{models}->{over_under_model};
	my $over_under = $self->{models}->{over_under_model};

	for my $game (@{ $self->{fixtures} } ) {
		my $home = $game->{home_team};
		my $away = $game->{away_team};
		my $league = @{ $self->{leagues} }[$game->{league_idx}];

		$game->{home_over_under} = $league->get_home_over_under ($home);
		$game->{away_over_under} = $league->get_away_over_under ($away);
		$game->{home_last_six_over_under} = $league->get_last_six_over_under ($home);
		$game->{away_last_six_over_under} = $league->get_last_six_over_under ($away);
		$game->{home_away} = ($game->{home_over_under} + $game->{away_over_under}) / $stat_size;
		$game->{last_six} = ($game->{home_last_six_over_under} + $game->{away_last_six_over_under}) / $stat_size;
		$game->{ou_points} = $over_under->do_ou_points ($game);
		$game->{ou_points2} = $over_under->do_ou_points2 ($game);
	}

	$sorted->{ou_home_away} = $over_under->do_home_away ();
	$sorted->{ou_last_six} = $over_under->do_last_six ();
	$sorted->{ou_odds} = $over_under->do_over_under ();
	$sorted->{ou_points} = $over_under->do_over_under_points ();
	$sorted->{ou_points2} = $over_under->do_over_under_points2 ();  
	$sorted->{ou_unders} = $over_under->do_unders ();

	return $sorted;
}

#	helper method for benchtest scripts
sub get_data {
	my ($self, $sorted) = @_;
	return @{ $sorted->{expect} }[0];
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
