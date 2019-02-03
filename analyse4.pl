#	analyse4.pl 30/01 - 03/02/19

use strict;
use warnings;

use List::MoreUtils qw(pairwise);
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;
use Football::Globals qw(@csv_leagues @league_names);

use Football::BenchTest::BenchTest_Model;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::Football_Data_Model;
use MyJSON qw(read_json write_json);

my $leagues = { pairwise { $a => $b } @league_names, @csv_leagues };
my $expect_data = read_json ('C:/Mine/perl/Football/data/benchtest/test data/goal_expect_test.json');
my $results_json = 'C:/Mine/perl/Football/data/benchtest/results.json';

my $bt_model = Football::BenchTest::BenchTest_Model->new ();
my $expect_model = Football::BenchTest::Goal_Expect_Model->new ();
my $data_model = Football::BenchTest::Football_Data_Model->new ();

for my $game (@$expect_data) {
    $game->{result} = $data_model->get_result ($leagues->{$game->{league}},$game->{home_team}, $game->{away_team});
}
$expect_data = $bt_model->remove_postponed ($expect_data);

my $results = {};
my $results_data = (-e $results_json) ? read_json ($results_json) : [];

print "\n\nNumber of matches : ". scalar @$expect_data;
for (my $i = 0; $i <=3; $i+=0.5) {
    $results->{home_away}->{$i} = {
        wins => scalar @{ $expect_model->home_away_wins ($expect_data, $i) },
        from => scalar @{ $expect_model->home_away_games ($expect_data, $i) },
    };
    $results->{last_six}->{$i} = {
        wins => scalar @{ $expect_model->last_six_wins ($expect_data, $i) },
        from => scalar @{ $expect_model->last_six_games ($expect_data, $i) },
    };
    $results->{ha_lsx}->{$i} = {
        wins => scalar @{ $expect_model->ha_lsx_wins ($expect_data, $i) },
        from => scalar @{ $expect_model->ha_lsx_games ($expect_data, $i) },
    };
    print "\n\nHome Away $i : ". $results->{home_away}->{$i}->{wins}.' from '.$results->{home_away}->{$i}->{from};
    print "\nLast Six  $i : ". $results->{last_six}->{$i}->{wins}.' from '.$results->{last_six}->{$i}->{from};
    print "\nBoth      $i : ". $results->{ha_lsx}->{$i}->{wins}.' from '.$results->{ha_lsx}->{$i}->{from};
}
<STDIN>;
print Dumper $results;
push @$results_data, $results;
write_json ($results_json, $results_data);
