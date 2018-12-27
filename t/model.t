
#	Model.t 01/05/16, 07/11/17

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1;}

use strict;
use warnings;
use Test::More tests => 8;
use Test::Deep;
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::HomeTable;
use Football::AwayTable;
use MyJSON qw(read_json);

my $model = Football::Model->new ();
my ($games, $leagues, $fixture_list, $data);
my ($homes, $aways, $last_six);

my $test_path = 'C:/Mine/perl/Football/t/test data/';

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Model', '$model');
};

subtest 'build_leagues' => sub {
	plan tests => 1;

	$games = $model->read_games (0);
	$leagues = $model->build_leagues ($games);
	isa_ok (@$leagues [0], 'Football::League', '@$leagues[0]');
};

#	no longer used
subtest 'Football_IO_Role routines' => sub {
	plan tests => 4;

	$games = $model->read_games ();
	$fixture_list = $model->get_fixtures ();

	isa_ok ($games, 'HASH','$games');
	isa_ok ($fixture_list, 'ARRAY', '$fixture_list');
	is (@$fixture_list[0]->{home_team}, 'West Ham', 'fixture list home team ok');
	is (@$fixture_list[1]->{away_team}, 'Stoke', 'fixture list away team ok');
};

subtest 'Shared_Model routines' => sub {
	plan tests => 8;

	my $home_table = $model->do_home_table ($games);
	my $away_table = $model->do_away_table ($games);

	isa_ok ($home_table, 'ARRAY', '$home table');
	isa_ok ($away_table, 'ARRAY', '$away table');
	isa_ok (@$home_table[0]->{home_table}, 'Football::HomeTable', '$home table[0]');
	isa_ok (@$away_table[0]->{away_table}, 'Football::AwayTable', '$away table[0]');

	$homes = $model->do_homes ($leagues);
	$aways = $model->do_aways ($leagues);
	$last_six = $model->do_last_six ($leagues);

	isa_ok (@$homes[0]->{homes}, 'HASH', '$homes');
	isa_ok (@$aways[0]->{aways}, 'HASH', '$aways');
	isa_ok (@$last_six[0]->{last_six}, 'HASH', '$last_six');

	$data = $model->do_fixtures ($fixture_list, $homes, $aways, $last_six);
	isa_ok ($data, 'HASH', '$data');
};

subtest 'Goal Expect Model' => sub {
	plan tests => 6;

	my ($teams, $sorted) = $model->do_predict_models ($data->{by_match}, $leagues);
#	my ($teams, $sorted) = $model->do_predict_models ($leagues, $fixture_list, $stats, "Football");
	isa_ok ($teams, 'HASH', '$teams');
	isa_ok ($sorted, 'HASH', '$sorted');

	is ($teams->{Stoke}->{av_home_for}, 1.33, 'Stoke - Average home for 1.33');
	is ($teams->{Stoke}->{av_home_against}, 1.83, 'Stoke - Average home against 1.83');
	is ($teams->{Stoke}->{av_away_for}, 1.17, 'Stoke - Average away for 1.17');
	is ($teams->{Stoke}->{av_away_against}, 2.17, 'Stoke - Average away against 2.17');
};

subtest 'get_unique_leagues' => sub {
	plan tests => 1;

	my $unique_file = "test data/unique leagues.json";
	my $expect = read_json ($unique_file);

	my $fixtures = $model->get_fixtures ( testing => 1 );
	my $leagues = $model->get_unique_leagues ($fixtures);
	cmp_deeply ($leagues, $expect, 'got unique leagues');
};

# Shared Model
subtest 'get_league_idx' => sub {
	plan tests => 3;

	is ($model->get_league_idx ('Premier League'), 0, 'Premier League idx 0');
	is ($model->get_league_idx ('Conference'), 4, 'Conference 4');
	is ($model->get_league_idx ('Scots League Two'), 8, 'Scots League Two idx 8');
};

subtest 'Team_Data access methods' => sub {
#	Refactored hash access in Football::Roles::Shared Model into Football::League methods,
#	then from Football::League into Football::Roles::Team_Data December 2018
	plan tests => 4;

	cmp_deeply (@$leagues[0]->{homes}->{Stoke}->{homes}, @$leagues[0]->get_homes ('Stoke'), 'get_homes');
	cmp_deeply (@$leagues[0]->{aways}->{Stoke}->{aways}, @$leagues[0]->get_aways ('Stoke'), 'get_aways');
	cmp_deeply (@$leagues[0]->{homes}->{Stoke}->{full_homes}, @$leagues[0]->get_full_homes ('Stoke'), 'get_full_homes');
	cmp_deeply (@$leagues[0]->{aways}->{Stoke}->{full_aways}, @$leagues[0]->get_full_aways ('Stoke'), 'get_full_aways');
};

#	tests to do :

#	Model routines
#	do_league_places
#	do_head2head
#	do_recent_goal_difference
#	do_goal_difference
#	fetch_goal_difference
#	do_recent_draws
#	do_favourites
#	do_over_under
