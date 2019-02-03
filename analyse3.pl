#	analyse3.pl 30/01/19

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref pairwise);
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

print "Number of matches : ". scalar @$expect_data;
my $ha_wins = $expect_model->home_away_wins ($expect_data);
print "\nNumber of home away wins : ". scalar @$ha_wins.' from '.scalar @$expect_data;

my $lsx_wins = $expect_model->last_six_wins ($expect_data);
print "\nNumber of last six wins : ". scalar @$lsx_wins.' from '.scalar @$expect_data;

print "\n\nHome Away :";
for my $game (@$ha_wins) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}";
}

print "\n\nLast Six :";
for my $game (@$lsx_wins) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff_last_six}";
}

my $poss = $expect_model->ha_lsx_games ($expect_data);
print "\n\nPossible : ".scalar(@$poss);
for my $game (@$poss) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}, $game->{expected_goal_diff_last_six}";
}
<STDIN>;

my $both = $expect_model->ha_lsx_wins ($expect_data);
print "\n\nNumber of both : ".scalar @$both.' from '.scalar @$poss;
for my $game (@$both) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}, $game->{expected_goal_diff_last_six}";
}

my $lost = $expect_model->ha_lsx_lost ($expect_data);
print "\n\nNumber of lost : ".scalar @$lost.' from '.scalar @$poss;
for my $game (@$lost) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}, $game->{expected_goal_diff_last_six}";
}

print "\n\nNumber of matches : ". scalar @$expect_data;
print "\nNumber of home away wins : ". scalar @$ha_wins.' from '.scalar @$expect_data;
print "\nNumber of last six wins : ". scalar @$lsx_wins.' from '.scalar @$expect_data;
print "\n\nPossible : ".scalar(@$poss);
print "\nNumber of both : ".scalar @$both.' from '.scalar @$poss;
print "\nNumber of lost : ".scalar @$lost.' from '.scalar @$poss;

print "\n\nNumber of matches : ". scalar @$expect_data;
#my $results = {};
for (my $i = 0; $i <=3; $i+=0.5) {
    my $ha = $expect_model->home_away_games ($expect_data, $i);
    my $ha_wins = $expect_model->home_away_wins ($expect_data, $i);
    my $lsx = $expect_model->last_six_games ($expect_data, $i);
    my $lsx_wins = $expect_model->last_six_wins ($expect_data, $i);
    my $ha_lsx = $expect_model->ha_lsx_games ($expect_data, $i);
    my $ha_lsx_wins = $expect_model->ha_lsx_wins ($expect_data, $i);

    print "\nHome Away $i : ". scalar @$ha_wins.' from '.scalar @$ha;
    print "\nLast Six  $i : ". scalar @$lsx_wins.' from '.scalar @$lsx;
    print "\nBoth      $i : ". scalar @$ha_lsx_wins.' from '.scalar @$ha_lsx;
#    for my $game (@$ha_wins2) {
#        print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}";
#        $results->{home_away}->{$i}->{wins} = scalar @$ha_wins2;
#        $results->{home_away}->{$i}->{from} = scalar @$ha;
#    }
    <STDIN>;
}

my $results = {};
my $results_data = (-e $results_json) ? read_json ($results_json) : [];
print Dumper $results_data; <STDIN>;

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
}
print Dumper $results;
push @$results_data, $results;
write_json ($results_json, $results_data);
