
#   backtest_sqrt.pl 23-26/03/19

use strict;
use warnings;

use Football::Globals qw(@league_names @csv_leagues);
use Football::Game_Prediction_Models;
use Football::BenchTest::Season;
use Football::BenchTest::FileList;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Goal_Diffs_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::OU_Points_Model;
use Football::BenchTest::Spreadsheets::BenchTest_View;
use Football::BenchTest::Goal_Expect_Override;

my $filename = 'C:/Mine/perl/Football/reports/backtest_sqrt.xlsx';
my $models = [
    Football::BenchTest::Goal_Expect_Model->new (),
    Football::BenchTest::Goal_Diffs_Model->new (),
    Football::BenchTest::Over_Under_Model->new (),
    Football::BenchTest::OU_Points_Model->new (),
];

my $file_list = Football::BenchTest::FileList->new (
    leagues     => \@league_names,
    csv_leagues => \@csv_leagues,
);
my $files = $file_list->get_current ();

my $season = Football::BenchTest::Season->new (
    models      => $models,
    files       => $files,
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
        fixtures    => [ $game ],
        leagues     => [ $league ],
        model       => Football::BenchTest::Goal_Expect_Override->new ( fixtures => [$game], leagues => [$league] ),
#        model       => Football::BenchTest::Goal_Expect_Override->new (),
    );

	my ($teams, $sorted) = $predict_model->calc_goal_expect ();
    $sorted->{over_under} = $predict_model->calc_over_under ();

    my $data = @{ $sorted->{expect} }[0];
    return $data;
}
