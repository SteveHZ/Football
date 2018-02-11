#!	C:/Strawberry/perl/bin

#	Model.t 01/05/16, 07/11/17

use strict;
use warnings;
use Test::More tests => 6;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Football::Model;
use MyJSON qw(read_json);

my $model = Football::Model->new ();
my ($games, $leagues, $fixture_list);

my $test_path = "C:/Mine/perl/Football/t/test data/";

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Model', '$model');
};

subtest 'Football_IO_Role routines' => sub {
	plan tests => 4;

	$model->{fixtures_file} = $test_path."football fixtures.csv";
	$games = $model->read_games (testing => 1); # no update, read test data file
	$fixture_list = $model->get_fixtures ();

	isa_ok ($games, 'HASH','$games');
	isa_ok ($fixture_list, 'ARRAY', '$fixture_list');
	is (@$fixture_list[0]->{home_team}, "West Ham", "fixture list home team ok");
	is (@$fixture_list[1]->{away_team}, "Stoke", "fixture list away team ok");
};

subtest 'build_leagues' => sub {
	plan tests => 1;

	$leagues = $model->build_leagues ($games);
	isa_ok (@$leagues [0], 'Football::League', '@$leagues[0]');
};

my ($home_table, $away_table);
my ($homes, $aways, $last_six, $fixtures);

subtest 'Shared_Model routines' => sub {
	plan tests => 8;

	$home_table = $model->do_home_table ($games);
	$away_table = $model->do_away_table ($games);
	
	isa_ok ($home_table, 'ARRAY', '$home table');
	isa_ok ($away_table, 'ARRAY', '$away table');
	isa_ok (@$home_table[0]->{home_table}, 'Football::HomeTable', '$home table[0]');
	isa_ok (@$away_table[0]->{away_table}, 'Football::AwayTable', '$away table[0]');

	$homes = $model->homes ($leagues);
	$aways = $model->aways ($leagues);
	$last_six = $model->last_six ($leagues);

	isa_ok (@$homes[0]->{homes}, 'HASH', '$homes');
	isa_ok (@$aways[0]->{aways}, 'HASH', '$aways');
	isa_ok (@$last_six[0]->{last_six}, 'HASH', '$last_six');

	$fixtures = $model->do_fixtures ($fixture_list, $homes, $aways, $last_six);
	isa_ok ($fixtures, 'ARRAY', '$fixtures');
};

my ($teams, $sorted);

subtest 'Goal Expect Model' => sub {
	plan tests => 6;
	
	($teams, $sorted) = $model->do_predict_models ($leagues, $fixture_list, "Football");
	isa_ok ($teams, 'HASH', '$teams');
	isa_ok ($sorted, 'HASH', '$sorted');

	is ($teams->{Stoke}->{av_home_for}, 1.33, "Stoke - Average home for 1.33");
	is ($teams->{Stoke}->{av_home_against}, 1.83, "Stoke - Average home against 1.83");
	is ($teams->{Stoke}->{av_away_for}, 1.17, "Stoke - Average away for 1.17");
	is ($teams->{Stoke}->{av_away_against}, 2.17, "Stoke - Average away against 2.17");
};

subtest 'get_unique_leagues' => sub {
	plan tests => 1;
	
	my $unique_file = "test data/unique leagues.json";
	my $expect = read_json ($unique_file);
	
	my $fixtures = $model->get_fixtures ( testing => 1 );
	my $leagues = $model->get_unique_leagues ($fixtures);
	cmp_deeply ($leagues, $expect, 'got unique leagues');
};

=head
tests to do :

Model routines
do_league_places
do_head2head
do_recent_goal_difference
do_goal_difference
fetch_goal_difference
do_recent_draws
do_favourites
do_over_under
=cut
