package Football::Game_Predictions::Model;

use v5.10; # state
use Football::Game_Predictions::Goal_Expect_Model;
use Football::Game_Predictions::Match_Odds;
#use Football::Game_Predictions::Skellam_Dist_Model;
use Football::Game_Predictions::Over_Under_Model;
use Football::Globals qw( $default_stats_size );
use Football::Rules;
use MyJSON qw(write_json);

use Moo;
use namespace::clean;

has 'fixtures' => (is => 'ro', default => sub { [] }, required => 1);
has 'leagues' => (is => 'ro', default => sub { [] }, required => 1);
has 'expect_model' => (is => 'ro', default => sub { {} });

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

	my $expect = $self->{expect_model} = Football::Game_Predictions::Goal_Expect_Model->new (
		fixtures => $self->{fixtures},
		leagues => $self->{leagues},
	);
	my $teams = $expect->calc_goal_expects ();
	for my $game ( $self->{fixtures}->@* ) {
		$expect->calc_expected_scores ($teams, $game);
		$expect->calc_goal_diffs ($teams, $game);
	}
	return $teams;
}

sub sort_expect_data {
	my $self = shift;
	die "No model defined !!" unless defined $self->{expect_model};
	return $self->{expect_model}->sort_expect_data ('expected_goal_diff');
}

sub calc_match_odds {
	my ($self, $model_name) = @_;
	my $odds = Football::Game_Predictions::Match_Odds->new (max => 5);
#	my $odds = Football::Game_Predictions::Match_Odds->new (max => 5, weighted => 0);

	for my $game ( $self->{fixtures}->@* ) {
		$game->{odds} = $self->get_odds ($odds, $game);
	}

	my $sorted = $odds->sort_sheets ($self->{fixtures});
#	Write out data to then read from value.pl
	$odds->save_match_odds ($sorted->{home_win}, $self->{path}->{$model_name});
	return $sorted;
}

sub get_odds {
	my ($self, $odds, $game) = @_;
	return {
		season => $odds->calc_odds ($game->{home_goals}, $game->{away_goals}),
		last_six => $odds->calc_odds ($game->{home_last_six}, $game->{away_last_six}),
	};
}

sub calc_skellam_dist {
	my $self = shift;
	my $skellam = Football::Game_Predictions::Skellam_Dist_Model->new ();

	for my $game ( $self->{fixtures}->@* ) {
		$game->{skellam} = $skellam->calc ($game);
	}
	return $skellam->schwartz_sort ($self->{fixtures});
}

sub calc_over_under {
	my $self = shift;
	my $over_under = Football::Game_Predictions::Over_Under_Model->new (
		fixtures => $self->{fixtures},
		leagues => $self->{leagues},
	);
	my $stat_size = $default_stats_size * 2;

	for my $game ( $self->{fixtures}->@* ) {
		my $home = $game->{home_team};
		my $away = $game->{away_team};
		my $league = $self->{leagues}[$game->{league_idx}];

		$game->{home_over_under} = $league->get_home_over_under ($home);
		$game->{away_over_under} = $league->get_away_over_under ($away);
		$game->{home_last_six_over_under} = $league->get_last_six_over_under ($home);
		$game->{away_last_six_over_under} = $league->get_last_six_over_under ($away);
		$game->{home_away} = ($game->{home_over_under} + $game->{away_over_under}) / $stat_size;
		$game->{last_six} = ($game->{home_last_six_over_under} + $game->{away_last_six_over_under}) / $stat_size;
		$game->{ou_points} = $over_under->do_ou_points ($game);
		$game->{ou_points2} = $over_under->do_ou_points2 ($game);
	}

	return {
		ou_home_away => $over_under->do_home_away (),
		ou_last_six => $over_under->do_last_six (),
		ou_odds => $over_under->do_over_under (),
		ou_points => $over_under->do_over_under_points (),
		ou_points2 => $over_under->do_over_under_points2 (),
		ou_unders => $over_under->do_unders (),
	};
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
		$rules->ou_points_rule ( $game ),
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
