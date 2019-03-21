
#   backtest.pl 01-19/03/19

use strict;
use warnings;

use Football::Globals qw(@league_names @csv_leagues);
use Football::Game_Prediction_Models;
use Football::BenchTest::Season;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Goal_Diffs_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::OU_Points_Model;
use Football::BenchTest::Spreadsheets::BenchTest_View;
use MyJSON qw(read_json);

my $filename = 'C:/Mine/perl/Football/reports/backtest.xlsx';
my $models = [
    Football::BenchTest::Goal_Expect_Model->new (),
    Football::BenchTest::Goal_Diffs_Model->new (),
    Football::BenchTest::Over_Under_Model->new (),
    Football::BenchTest::OU_Points_Model->new (),
];

my $season = Football::BenchTest::Season->new (
    models      => $models,
    leagues     => \@league_names,
    csv_leagues => \@csv_leagues,
    callback    => \&do_predict_models,
);
$season->run ();

my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new (
    models      => $models,
    filename    => $filename,
);
$bt_view->write ();

sub do_predict_models {
	my ($self, $game, $league) = @_;
	my $predict_model = Football::Game_Prediction_Models->new (
		fixtures => [ $game ] , leagues => [ $league ] );

	my ($teams, $sorted) = $predict_model->calc_goal_expect ();
    $sorted->{over_under} = $predict_model->calc_over_under ();

    my $data = @{ $sorted->{expect} }[0];
    return $data;
}
