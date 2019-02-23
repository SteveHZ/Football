#	analyse4.pl 30/01 - 23/02/19

# need to add ou_ha_lsx to to model and Spreadsheet
# also llok at h/a for ou_points rather than l6 @games
# OR figure out new algo for points see Plymouth Rochdale (maybe save to file for later)

use strict;
use warnings;

use lib "C:/Mine/perl/Football";
use Football::BenchTest::BenchTest_Model;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::Football_Data_Model;
use Football::BenchTest::Spreadsheets::BenchTest_View;

use MyJSON qw(read_json write_json);
use MyLib qw(prompt);

print "\nLoading data...";
my $update = (defined $ARGV[0] && $ARGV[0] eq '-u') ? 1 : 0;
my $json_file = ($update) ? 'C:/Mine/perl/Football/data/benchtest/predictions_prev.json'
                          : 'C:/Mine/perl/Football/data/benchtest/test data/goal_expect_test.json';
my $expect_data = read_json ($json_file);
my $totals_file = 'C:/Mine/perl/Football/data/benchtest/totals.json';

my $bt_model = Football::BenchTest::BenchTest_Model->new ();
my $expect_model = Football::BenchTest::Goal_Expect_Model->new ();
my $ou_model = Football::BenchTest::Over_Under_Model->new ();
my $data_model = Football::BenchTest::Football_Data_Model->new ();

print "\nLoading results...";
my $leagues = $bt_model->league_hash;
for my $game (@$expect_data) {
    $game->{result} = $data_model->get_result ($leagues->{$game->{league}}, $game->{home_team}, $game->{away_team});
    $game->{over_under} = $data_model->get_over_under_result ($leagues->{$game->{league}}, $game->{home_team}, $game->{away_team});
}
$expect_data = $bt_model->remove_postponed ($expect_data);

print "\nBuilding weekly results...";
my $week = {};
$expect_model->get_results ($week, $expect_data);
$ou_model->get_results ($week, $expect_data);

print "\nLoading historical data...";
my $totals = read_json ($totals_file);
if ($update) {
    print "\nUpdating totals...";
    $expect_model->update_totals ($week, $totals);
    $ou_model->update_totals ($week, $totals);
    write_json ($totals_file, $totals);

    my $date = prompt ('Enter date for backup (yyyymmdd)');
    $bt_model->do_backup ($date, $expect_data);
}

my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new ();
$bt_view->write ($totals);
