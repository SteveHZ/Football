#	analyse2.pl 30/01/19

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref pairwise);
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;
use Football::Globals qw(@csv_leagues @league_names);

use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::Football_Data_Model;
use Football::BenchTest::Utils qw(get_league make_csv_file_list make_file_list);
use MyJSON qw(read_json write_json);

my $leagues = { pairwise { $a => $b } @league_names, @csv_leagues };
my $expect_data = read_json ('C:/Mine/perl/Football/data/benchtest/goal_expect_test.json');

my $expect_model = Football::BenchTest::Goal_Expect_Model->new ();
my $data_model = Football::BenchTest::Football_Data_Model->new ();

for my $game (@$expect_data) {
    $game->{result} = $data_model->get_result ($leagues->{$game->{league}},$game->{home_team}, $game->{away_team});
}
print Dumper $expect_data;

print "Number of matches : ". scalar @$expect_data;
my @ha_wins =
    sort {$b->{expected_goal_diff} <=> $a->{expected_goal_diff}}
    grep {
        ( $_->{expected_goal_diff} > 0 && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff} < 0 && $_->{result} eq 'A')
    } @$expect_data;
print "\nNumber of home away wins : ". scalar @ha_wins.' from '.scalar @$expect_data;

my @ls_wins =
    sort {$b->{expected_goal_diff_last_six} <=> $a->{expected_goal_diff_last_six}}
    grep {
        ( $_->{expected_goal_diff_last_six} > 0 && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff_last_six} < 0 && $_->{result} eq 'A')
    } @$expect_data;
print "\nNumber of last six wins : ". scalar @ls_wins.' from '.scalar @$expect_data;

print "\n\nHome Away :";
for my $game (@ha_wins) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}";
}

print "\n\nLast Six :";
for my $game2 (@ls_wins) {
    print "\n$game2->{home_team} v $game2->{away_team}, $game2->{result}, $game2->{expected_goal_diff_last_six}";
}

my @poss =
    grep {
        ( $_->{expected_goal_diff} > 0 && $_->{expected_goal_diff_last_six} > 0 )
        or ( $_->{expected_goal_diff} < 0 && $_->{expected_goal_diff_last_six} < 0)
    } @$expect_data;

print "\n\nPossible : ".scalar(@poss);
for my $game3 (@poss) {
    print "\n$game3->{home_team} v $game3->{away_team}, $game3->{result}, $game3->{expected_goal_diff}, $game3->{expected_goal_diff_last_six}";
}

my @both =
    grep {
        (( $_->{expected_goal_diff} > 0 && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff} < 0 && $_->{result} eq 'A'))
        &&
        (( $_->{expected_goal_diff_last_six} > 0 && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff_last_six} < 0 && $_->{result} eq 'A'))
    } @$expect_data;

print "\n\nNumber of both : ".scalar @both.' from '.scalar @poss;
for my $game4 (@both) {
    print "\n$game4->{home_team} v $game4->{away_team}, $game4->{result}, $game4->{expected_goal_diff}, $game4->{expected_goal_diff_last_six}";
}

my @lost =
    grep {
        (( $_->{expected_goal_diff} < 0 && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff} > 0 && $_->{result} eq 'A'))
        &&
        (( $_->{expected_goal_diff_last_six} < 0 && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff_last_six} > 0 && $_->{result} eq 'A'))
    } @$expect_data;

print "\n\nNumber of lost : ".scalar @lost.' from '.scalar @poss;
for my $game5 (@lost) {
    print "\n$game5->{home_team} v $game5->{away_team}, $game5->{result}, $game5->{expected_goal_diff}, $game5->{expected_goal_diff_last_six}";
}

print "\n\nNumber of matches : ". scalar @$expect_data;
print "\nNumber of home away wins : ". scalar @ha_wins.' from '.scalar @$expect_data;
print "\nNumber of last six wins : ". scalar @ls_wins.' from '.scalar @$expect_data;
print "\n\nPossible : ".scalar(@poss);
print "\nNumber of both : ".scalar @both.' from '.scalar @poss;
print "\nNumber of lost : ".scalar @lost.' from '.scalar @poss;
