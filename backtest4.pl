
#   backtest.pl 01-14/03/19

use strict;
use warnings;

use Football::Globals qw(@league_names @csv_leagues);
use Football::BenchTest::Season;

use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Goal_Diffs_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::OU_Points_Model;
use Football::BenchTest::Spreadsheets::BenchTest_View;

use MyJSON qw(read_json);
use Data::Dumper;

my $path = 'C:/Mine/perl/Football/data/';
my $teams_file = $path.'teams.json';
my $teams = read_json ( $teams_file );

my $filename = 'C:/Mine/perl/Football/reports/backtest4.xlsx';
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
);
my $count = $season->run ();

my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new (
    models      => $models,
    filename    => $filename,
);
$bt_view->write ();
