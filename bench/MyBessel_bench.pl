#	MyBessel_bench 01/10/17, 04/10/17, 12/10/17
#	v1.1 reworked 04/01/19, 22/01/19 after Football::Model refactor 2018

use strict;
use warnings;

use lib '../../Football';
use Football::Model;
use Football::Skellam_Dist_Model;
use Benchmark qw(timethese cmpthese);

my $model = Football::Model->new ();
my $data = $model->build_data ();

my $fixtures = $model->get_fixtures ();
my $stats = $model->do_fixtures ($fixtures, $data->{homes}, $data->{aways}, $data->{last_six});

$model->do_recent_goal_difference ($stats->{by_league}, $data->{leagues});
$model->do_goal_difference ($stats->{by_league}, $data->{leagues});
$model->do_league_places ($stats->{by_league}, $data->{leagues});
$model->do_head2head ($stats->{by_league});
$model->do_recent_draws ($stats->{by_league});

my ($teams, $sorted) = $model->do_predict_models ($data->{by_match}, $data->{leagues});

do_skellam_benchmark ($sorted->{expect});

sub do_skellam_benchmark {
	my $fixtures = shift;
	my $skellam = Football::Skellam_Dist_Model->new ();

	print "\nSkellam Distibution Model Benchmark :\n\n";
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
