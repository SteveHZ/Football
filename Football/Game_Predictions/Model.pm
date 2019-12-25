package Football::Game_Predictions::Model;

use v5.10; # $state
use Football::Game_Predictions::Goal_Expect_Model;
use Football::Game_Predictions::Match_Odds;
use Football::Game_Predictions::Skellam_Dist_Model;
use Football::Game_Predictions::Over_Under_Model;
use Football::Globals qw( $default_stats_size );
use Football::Rules;
use MyJSON qw(write_json);

use Moo;
use namespace::clean;

#	models can be defined by Football::BenchTest::Adapter::Game_Prediction_Models
has 'models' => (is => 'ro', default => sub { {} });
has 'fixtures' => (is => 'ro', default => sub { [] }, required => 1);
has 'leagues' => (is => 'ro', default => sub { [] }, required => 1);

sub BUILD {
	my $self = shift;
	$self->{path} = {
		'UK' => 'C:/Mine/perl/Football/data',
		'Euro' => 'C:/Mine/perl/Football/data/Euro',
		'Summer' => 'C:/Mine/perl/Football/data/Summer',
	};
}

sub calc_goal_expect {
	my $self = shift;

	$self->{models}->{expect_model} = Football::Game_Predictions::Goal_Expect_Model->new (
		fixtures => $self->{fixtures},
		leagues => $self->{leagues},
	) unless defined $self->{models}->{expect_model};
	my $expect = $self->{models}->{expect_model};

	my $teams = $expect->calc_goal_expects ();
	for my $game ( $self->{fixtures}->@* ) {
		$expect->calc_expected_scores ($teams, $game);
		$expect->calc_goal_diffs ($teams, $game);
	}

	my $sorted = $expect->sort_expect_data ('expected_goal_diff');
	return ($teams, $sorted);
}

sub calc_match_odds {
	my ($self, $model_name) = @_;

	$self->{models}->{odds_model} = Football::Game_Predictions::Match_Odds->new ()
#	$self->{models}->{odds_model} = Football::Game_Predictions::Match_Odds->new (max => 6)
		unless defined $self->{models}->{odds_model};
	my $odds = $self->{models}->{odds_model};

	for my $game ( $self->{fixtures}->@* ) {
#		$odds->calc ($game->{home_goals}, $game->{away_goals});
		$odds->calc_weighted ($game->{home_goals}, $game->{away_goals});

		$game->{home_win} = $odds->home_win_odds ();
		$game->{away_win} = $odds->away_win_odds ();
		$game->{draw} = $odds->draw_odds ();
		$game->{both_sides_yes} = $odds->both_sides_yes_odds ();
		$game->{both_sides_no} = $odds->both_sides_no_odds ();
		$game->{under_2pt5} = $odds->under_2pt5_odds ();
		$game->{over_2pt5} = $odds->over_2pt5_odds ();
	}
	my $sorted = $odds->sort_sheets ($self->{fixtures});
	$odds->save_match_odds ($sorted->{home_win}, $self->{path}->{$model_name});
	return $sorted;
}

sub calc_skellam_dist {
	my $self = shift;

	$self->{models}->{skellam_model} = Football::Game_Predictions::Skellam_Dist_Model->new ()
		unless defined $self->{models}->{skellam_model};
	my $skellam = $self->{models}->{skellam_model};

	for my $game ( $self->{fixtures}->@* ) {
		$game->{skellam} = $skellam->calc ($game->{home_goals}, $game->{away_goals});
	}
	return $skellam->schwartz_sort ($self->{fixtures});
}

sub calc_over_under {
	my $self = shift;
	my $stat_size = $default_stats_size * 2;

	my $sorted = {};
	$self->{models}->{over_under_model} = Football::Game_Predictions::Over_Under_Model->new (
		fixtures => $self->{fixtures},
		leagues => $self->{leagues},
	) unless defined $self->{models}->{over_under_model};
	my $over_under = $self->{models}->{over_under_model};

	for my $game ( $self->{fixtures}->@* ) {
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

sub save_expect_data {
	my ($self, $sorted, $model_name) = @_;
	my $filename = "C:/Mine/perl/Football/data/combine data/expect $model_name.json";
	my @data = ();

	for my $game (@$sorted) {
		push @data, $self->get_expect_line_data ($game);
	}
    write_json ($filename, \@data);
	return \@data;
}

sub get_expect_line_data {
	my ($self, $game) = @_;
	state $rules = Football::Rules->new ();

	return [
		$game->{league}, $game->{date}, $game->{home_team}, $game->{away_team},
		$game->{home_goals}, $game->{away_goals}, $game->{expected_goal_diff},
		$game->{home_last_six}, $game->{away_last_six}, $game->{expected_goal_diff_last_six},

		$rules->points_rule ( $game->{home_points}, $game->{away_points} ),
		$rules->points_rule ( $game->{last_six_home_points}, $game->{last_six_away_points} ),
		$rules->goal_diffs_rule ( $game->{rgd_results} ),
		$rules->goal_diffs_rule ( $game->{gd_results} ),

		$rules->home_away_rule ( $game ),
		$rules->last_six_rule ( $game ),

		$rules->match_odds_rule ( $game ),
		$rules->ou_points_rule ($game),
		$rules->ou_home_away_rule ( $game ),
		$rules->ou_last_six_rule ( $game ),
		$rules->over_odds_rule ( $game ),
		$rules->under_odds_rule ( $game ),
	];
}

#	helper method for benchtest scripts
sub get_data {
	my ($self, $sorted) = @_;
	return $sorted->{expect}->[0];
#	return @{ $sorted->{expect} }[0];
}

=pod

=head1 NAME

Football::Game_Prediction_Models.pm

=head1 SYNOPSIS

Model for Game_Prediction triad

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
