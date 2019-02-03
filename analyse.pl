#	analyse.pl 26/01/19

#BEGIN { $ENV{PERL_KEYWORD_ANALYSIS} = 1; }

use strict;
use warnings;
use Test::More tests => 1;
use List::MoreUtils qw(each_arrayref);
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;
use Football::Globals qw(@csv_leagues);

use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::Football_Data_Model;
use Football::BenchTest::Utils qw(get_league make_csv_file_list make_file_list);
use MyJSON qw(read_json write_json);

my $file = 'C:/Mine/perl/Football/data/benchtest/season.json';
my $model = Football::Model->new ( csv_leagues => [qw(E1 E2 E3)], league_names => ['Championship','League One','League Two']);
# DOESNT WORK !! - only reading one leagues so Model::build_leagues gets confused at $games->{league}
#my $data = $model->build_data ( {csv => 'C:/Mine/perl/Football/data/E1.csv'});
#my $data = $model->build_data ();
my $data = $model->build_data ({ json => $file });

my $fixtures = $model->get_fixtures ('C:/Mine/perl/football/data/benchtest/fixtures.csv');
#print Dumper $fixtures;<STDIN>;
#my $fixtures = get_league ($fixture_list, 'Championship');
my $stats = $model->do_fixtures ($fixtures, $data->{homes}, $data->{aways}, $data->{last_six});
my $predict_model = Football::Game_Prediction_Models->new (
	fixtures => $stats->{by_match},
	leagues => $data->{leagues},
);
my $ou_model = Football::Over_Under_Model->new (
	leagues => $data->{leagues},
	fixtures => $fixtures, stats => $stats
);

subtest 'constructor' => sub {
	use_ok 'Football::Over_Under_Model';
	isa_ok ($ou_model, 'Football::Over_Under_Model', '$ou_model');
	isa_ok ($predict_model, 'Football::Game_Prediction_Models', '$predict_model');
};
print Dumper $fixtures;

my $expect_model = Football::BenchTest::Goal_Expect_Model->new();
my $ou_model2 = Football::BenchTest::Over_Under_Model->new();

my ($teams, $sorted) = $predict_model->calc_goal_expect (1);#don't re-write json file
#print Dumper $teams;<STDIN>;
#print Dumper @{$sorted->{home_away}}[0];

my $sheets = [ qw(home_away last_six) ];
my $keys = [ qw(expected_goal_diff expected_goal_diff_last_six) ];

my $iterator = each_arrayref ($sheets, $keys);
while (my ($sheet, $key) = $iterator->()) {
	print "\n\n$sheet";
	for my $game (@{ $sorted->{$sheet} }) {
#	for my $i(0..11) {
#		my $game = @{ $sorted->{$sheet} }[$i];
		print "\n".$game->{home_team}.', ';
		print $game->{away_team}.', ';
		print $game->{$key};
	}
}

sub write_goal_expect {
	my ($self, $stats) = @_;
	my @list = ();
	for my $game (@$stats) {
#		my $expected_goal_diff = sprintf ("%0.2f", $game->{expected_goal_diff});
#		my $expected_goal_diff_last_six = sprintf ("%0.2f", $game->{expected_goal_diff_last_six});
#print "\n$expected_goal_diff - $expected_goal_diff_last_six";
		push @list, {
			home_team => $game->{home_team},
			away_team => $game->{away_team},
			expected_goal_diff => sprintf ("%0.2f", $game->{expected_goal_diff}),
			expected_goal_diff_last_six => sprintf ("%0.2f", $game->{expected_goal_diff_last_six}),
#			expected_goal_diff => $expected_goal_diff,
#			expected_goal_diff_last_six => $expected_goal_diff_last_six,
			league => $game->{league},
		}
	}
	<STDIN>;
	print Dumper @list;<STDIN>;
	write_json ('c:/mine/perl/football/data/benchtest/goal_expect_test.json', \@list);
}
=head
print "\n\nExpect";
for my $i(0..10) {
	my $game = @{ $sorted->{expect} }[$i];
	print "\n".$game->{home_team}.', ';
	print $game->{away_team}.', ';
	print $game->{expected_goal_diff}.', ';
}
print "\n\nHome Away";
for my $i(0..10) {
	my $game = @{ $sorted->{home_away} }[$i];
	print "\n".$game->{home_team}.', ';
	print $game->{away_team}.', ';
	print $game->{home_away_goal_diff}.', ';
}
print "\n\nLast Six";
for my $i(0..10) {
	my $game = @{ $sorted->{last_six} }[$i];
	print "\n".$game->{home_team}.', ';
	print $game->{away_team}.', ';
	print $game->{last_six_goal_diff}.', ';
}
=cut
print "\n\nGrepped";
for my $i(0..scalar @{$sorted->{grepped}}-1) {
	my $game = @{ $sorted->{grepped} }[$i];
	print "\n".$game->{home_team}.', ';
	print $game->{away_team};
#	print @{$sorted->{home_away}}[$i]->{home_away_goal_diff}.', ';
}

print "\n\nDBI :\n";
my $data_model = Football::BenchTest::Football_Data_Model->new ();
my $result = $data_model->get_result ('E1','Sheffield United','Swansea');
print Dumper $result;

write_goal_expect (undef, $stats->{by_match});
