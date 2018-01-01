#!	C:/Strawberry/perl/bin

#	MyBessel_bench 01/10/17, 04/10/17, 12/10/17

use strict;
use warnings;

use Test::More tests => 1;

use lib '../../Football';
use Football::Model;
use Football::View;
#use Football::Game_Prediction_Models;
use Football::Skellam_Dist_Model;
use Benchmark qw(timethese cmpthese);

subtest 'Test 1' => sub {
	is (1,1,"Test");

	my $model = Football::Model->new ();
	my $view = Football::View->new ();

	my $games = $model->read_games ( "0" );
	my $leagues = $model->build_leagues ($games);

	$view->do_table ($leagues);
	$view->do_home_table ( $model->do_home_table ($games));
	$view->do_away_table ( $model->do_away_table ($games));

	my $homes = $model->homes ($leagues);
	my $aways = $model->aways ($leagues);

	my $last_six = $model->last_six ($leagues);
	my $fixture_list = $model->get_fixtures ();
	my $fixtures = $model->do_fixtures ($fixture_list, $homes, $aways, $last_six);

	$model->do_recent_goal_difference ($fixtures, $leagues);
	$model->do_goal_difference ($fixtures, $leagues);
	$model->do_league_places ($fixtures, $leagues); 
	$model->do_head2head ($fixtures);
	
	$model->do_recent_draws ($fixtures);

#	my $predict_model = Football::Game_Prediction_Models->new ();
#	my ($teams, $sorted) = $predict_model->calc_goal_expect ($leagues, $fixture_list, "Football");
	my ($teams, $sorted) = $model->do_goal_expect ($leagues, $fixture_list, "Football");

	$view->do_match_odds ($sorted);
	$view->do_over_under ($sorted);
	$view->do_goal_expect ($leagues, $teams, $sorted, $fixture_list);
	do_skellam_benchmark ($sorted->{expect});
};

sub do_skellam_benchmark {
	my $fixtures = shift;
	my $skellam = Football::Skellam_Dist_Model->new ();

	print "\n\nSkellam Distibution Model Benchmark :\n";
	my $t = timethese (-10, {
		"Simple sort" => sub {
			$skellam->simple_sort ($fixtures);
		},
		"Schwartzian sort" => sub {
			$skellam->schwartz_sort ($fixtures);
		},
		"Cache sort" => sub {
			$skellam->cache_sort ($fixtures);
		},
#		"My Transform sort" => sub {
#			$skellam->transform_sort ($fixtures);
#		},
	});
	cmpthese $t;
}
