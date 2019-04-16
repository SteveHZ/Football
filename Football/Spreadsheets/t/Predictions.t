#   Football/Spreadsheets/t/Predictions.t 16/04/19

use strict;
use warnings;

use Test::More tests => 1;
use Football::Model;
use Football::Spreadsheets::Predictions;

my $model = Football::Model->new ();
my $data = $model->quick_build ();

my $view = Football::Spreadsheets::Predictions->new ();
isa_ok ($view, 'Football::Spreadsheets::Predictions', 'Predictions spreadsheet');

print "\nWriting Predictions spreadsheet...";
$view->do_fixtures ( $data->{by_league} );
$view->do_last_six ( $data->{by_league} );
$view->do_head2head ( $model->do_head2head ($data->{by_league} ));
$view->do_league_places ( $model->do_league_places ($data->{by_league}, $model->leagues) );
$view->do_recent_goal_difference ( $model->do_recent_goal_difference ($data->{by_league}, $model->leagues) );
$view->do_goal_difference ( $model->do_goal_difference ($data->{by_league}, $model->leagues) );
$view->do_recent_draws ( $model->do_recent_draws ($data->{by_league} ) );
