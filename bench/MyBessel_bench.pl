#	MyBessel_bench 01/10/17, 04/10/17, 12/10/17
#	v1.1 reworked 04/01/19 after Football::Model refactor 2018

use strict;
use warnings;

use lib '../../Football';
use Football::Model;
use Football::View;
use Football::Skellam_Dist_Model;
use Benchmark qw(timethese cmpthese);

my $model = Football::Model->new ();
my $view = Football::View->new ();

my $games = $model->read_games ();
my $leagues = $model->build_leagues ($games);

$view->do_table ($leagues);
$view->do_home_table ( $model->do_home_table ($games));
$view->do_away_table ( $model->do_away_table ($games));

my $homes = $model->do_homes ($leagues);
my $aways = $model->do_aways ($leagues);
my $last_six = $model->do_last_six ($leagues);

my $fixtures = $model->get_fixtures ();
my $data = $model->do_fixtures ($fixtures, $homes, $aways, $last_six);

$model->do_recent_goal_difference ($data->{by_league}, $leagues);
$model->do_goal_difference ($data->{by_league}, $leagues);
$model->do_league_places ($data->{by_league}, $leagues);
$model->do_head2head ($data->{by_league});
$model->do_recent_draws ($data->{by_league});

my ($teams, $sorted) = $model->do_predict_models ($data->{by_match}, $leagues);
$view->do_predict_models ($leagues, $teams, $sorted);

do_skellam_benchmark ($sorted->{expect});

sub do_skellam_benchmark {
	my $fixtures = shift;
	my $skellam = Football::Skellam_Dist_Model->new ();

	print "\n\nSkellam Distibution Model Benchmark :\n";
	my $t = timethese (-10, {
		'Simple sort' => sub {
			$skellam->simple_sort ($fixtures);
		},
		'Schwartzian sort' => sub {
			$skellam->schwartz_sort ($fixtures);
		},
		'Cache sort' => sub {
			$skellam->cache_sort ($fixtures);
		},
#		'My Transform sort' => sub {
#			$skellam->transform_sort ($fixtures);
#		},
	});
	cmpthese $t;
}
