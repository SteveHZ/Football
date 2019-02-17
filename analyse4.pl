#	analyse4.pl 30/01 - 04/02/19

use strict;
use warnings;

use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;

use Football::BenchTest::BenchTest_Model;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::Football_Data_Model;
use Football::BenchTest::Spreadsheets::BenchTest_View;

use MyJSON qw(read_json write_json);
use MyLib qw(prompt);

my $update = (defined $ARGV[0] && $ARGV[0] eq '-u') ? 1 : 0;
my $json_file = ($update) ? 'C:/Mine/perl/Football/data/benchtest/predictions_prev.json'
                          : 'C:/Mine/perl/Football/data/benchtest/test data/goal_expect_test.json';
my $expect_data = read_json ($json_file);
my $results_json = 'C:/Mine/perl/Football/data/benchtest/results.json';

my $bt_model = Football::BenchTest::BenchTest_Model->new ();
my $expect_model = Football::BenchTest::Goal_Expect_Model->new ();
my $data_model = Football::BenchTest::Football_Data_Model->new ();

my $leagues = $bt_model->league_hash;
for my $game (@$expect_data) {
    $game->{result} = $data_model->get_result ($leagues->{$game->{league}},$game->{home_team}, $game->{away_team});
#    $game->{over_under} = $data_model->get_over_under_result ($leagues->{$game->{league}},$game->{home_team}, $game->{away_team});
#call as $game->{over_under}->{goals}
}
$expect_data = $bt_model->remove_postponed ($expect_data);

my $results = {};
my $results_data = (-e $results_json) ? read_json ($results_json) : [];

for (my $i = 0; $i <=3; $i+=0.5) {
    $results->{home_away}->{$i} = {
        wins => $expect_model->count_home_away_wins ($expect_data, $i),
        from => $expect_model->count_home_away_games ($expect_data, $i),
    };
    $results->{last_six}->{$i} = {
        wins => $expect_model->count_last_six_wins ($expect_data, $i),
        from => $expect_model->count_last_six_games ($expect_data, $i),
    };
    $results->{ha_lsx}->{$i} = {
        wins => $expect_model->count_ha_lsx_wins ($expect_data, $i),
        from => $expect_model->count_ha_lsx_games ($expect_data, $i),
    };
    print "\n\nHome Away $i : ". $results->{home_away}->{$i}->{wins}.' from '.$results->{home_away}->{$i}->{from};
    print "\nLast Six  $i : ". $results->{last_six}->{$i}->{wins}.' from '.$results->{last_six}->{$i}->{from};
    print "\nBoth      $i : ". $results->{ha_lsx}->{$i}->{wins}.' from '.$results->{ha_lsx}->{$i}->{from};
}

if ($update) {
    push @$results_data, $results;
    write_json ($results_json, $results_data);

    my $date = prompt ('Enter date for backup (yyyymmdd)');
    $bt_model->do_backup ($date, $expect_data);
}

my @keys = qw(home_away last_six ha_lsx);
my $totals = init_totals (\@keys);
for my $week (0...$#$results_data) {
    for my $key (@keys) {
        for (my $i = 0; $i <=3; $i+=0.5) {
            $totals->{$key}->{$i}->{wins} += @$results_data [$week]->{$key}->{$i}->{wins};
            $totals->{$key}->{$i}->{from} += @$results_data [$week]->{$key}->{$i}->{from};
        }
    }
}


my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new ();
$bt_view->write ($totals);

sub init_totals {
    my $keys = shift;
    my $totals = {};
    for my $key (@$keys) {
        for (my $i = 0; $i <=3; $i+=0.5) {
            $totals->{$key}->{$i}->{wins} = 0;
            $totals->{$key}->{$i}->{from} = 0;
        }
    }
    return $totals;
}

=cut
