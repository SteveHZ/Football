#   Football::BenchTest::Goal_Expect_Model.t 03/02/19

use strict;
use warnings;
use List::MoreUtils qw(pairwise true);
#use Data::Dumper;
use Test::More tests => 1;

=head
use MyJSON qw (read_json);
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::BenchTest_Model;
use Football::BenchTest::Football_Data_Model;
use Football::Globals qw(@league_names @csv_leagues);

#print Dumper @league_names;print Dumper @csv_leagues;
my $expect_model = Football::BenchTest::Goal_Expect_Model->new ();
my $data_model = Football::BenchTest::Football_Data_Model->new ();
#my $data_model = Football::BenchTest::Football_Data_Model->new (path => 'C:/Mine/perl/Football/data/benchtest');
my $bt_model = Football::BenchTest::BenchTest_Model->new ();

my $leagues = $bt_model->make_league_hash ();
my $expect_data = read_json ('C:/Mine/perl/Football/data/benchtest/test data/goal_expect_test.json');
print Dumper $expect_data;<STDIN>;
for my $game (@$expect_data) {
    $game->{result} = $data_model->get_result ($leagues->{$game->{league}},$game->{home_team}, $game->{away_team});
}
#$expect_data = $bt_model->remove_postponed ($expect_data);
#print Dumper $expect_data;<STDIN>;
is(1,1,'ok');

print "Number of matches : ". scalar @$expect_data;
my $ha_wins = $expect_model->home_away_wins ($expect_data);
print "\nNumber of home away wins : ". scalar @$ha_wins.' from '.scalar @$expect_data;

#my $lsx_wins = $expect_model->last_six_wins ($expect_data);
#print "\nNumber of last six wins : ". scalar @$lsx_wins.' from '.scalar @$expect_data;

print "\n\nHome Away :";
for my $game (@$ha_wins) {
    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}";
}

#print "\n\nLast Six :";
#for my $game (@$lsx_wins) {
#    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff_last_six}";
#}

#my $poss = $expect_model->ha_lsx_games ($expect_data);
#print "\n\nPossible : ".scalar(@$poss);
#for my $game (@$poss) {
#    print "\n$game->{home_team} v $game->{away_team}, $game->{result}, $game->{expected_goal_diff}, $game->{expected_goal_diff_last_six}";
#}

#subtest 'get_result' => sub {
#
#}
=cut
subtest 'abs' => sub {
    my $data = [-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8];
    for my $i (3..6) {
        my $result1 = count_home_away_games ($data,$i);
        my $result2 = count_home_away_games2 ($data,$i);
        is ($result1,$result2,"ok $i = $result1 and $result2");
    }
};

sub count_home_away_games {
    my ($data, $n) = @_;
    return true {
        $_ > $n
        or $_ < ($n * -1)
    } @$data;
}
sub count_home_away_games2 {
    my ($data, $n) = @_;
    return true {
        abs $_ > $n
    } @$data;
}
