#	analyse4.pl 30/01 - 21/02/19

use strict;
use warnings;
#use Data::Dumper;

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
my $results_json = 'C:/Mine/perl/Football/data/benchtest/results.json';

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
my $results = {};
$expect_model->get_results ($results, $expect_data);
$ou_model->get_results ($results, $expect_data);

print "\nWriting weekly results...";
my $results_data = (-e $results_json) ? read_json ($results_json) : [];
if ($update) {
    push @$results_data, $results;
    write_json ($results_json, $results_data);

    my $date = prompt ('Enter date for backup (yyyymmdd)');
    $bt_model->do_backup ($date, $expect_data);
}

#do I really need results_data week on week, could just store ongoing totals
#goal expect is already being saved week on week

print "\nUpdating totals...";
my $totals = {};
$expect_model->update_totals ($totals, $results_data);
$ou_model->update_totals ($totals, $results_data);

my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new ();
$bt_view->write ($totals);
