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
my $data = $model->build_data ();
my $fixtures = $model->get_fixtures ();
my $stats = $model->do_fixtures ($fixtures, $data->{homes}, $data->{aways}, $data->{last_six});

my $test_path = 'C:/Mine/perl/Football/t/test data/';

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Model', '$model');
};

subtest 'build_data' => sub {
	plan tests => 2;

	isa_ok (@{ $data->{leagues} } [0], 'Football::League', '$data->{leagues}');
	isa_ok ($data->{games}, 'HASH','$data->{games}');
};

subtest 'get_fixtures' => sub {
	plan tests => 3;

	isa_ok ($fixtures, 'ARRAY', '$fixtures');
	is (@$fixtures[0]->{home_team}, 'West Ham', 'fixture list home team ok');
	is (@$fixtures[1]->{away_team}, 'Stoke', 'fixture list away team ok');

};

subtest 'Shared_Model routines' => sub {
	plan tests => 8;
	my $league = @{ $data->{leagues} }[0];

	isa_ok ($data->{leagues}, 'ARRAY', '$data->{leagues}');
	isa_ok ($league->home_table, 'Football::HomeTable', 'home table');
	isa_ok ($league->away_table, 'Football::AwayTable', 'away table');

	isa_ok ($league->homes, 'HASH', 'homes');
	isa_ok ($league->aways, 'HASH', 'aways');
	isa_ok ($league->last_six, 'HASH', 'last_six');

	isa_ok ($fixtures, 'ARRAY', '$fixtures');
	isa_ok ($stats, 'HASH', '$stats');
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
	my $league = @{ $data->{leagues} }[0];

	cmp_deeply ($league->{homes}->{Stoke}->{homes}, $league->get_homes ('Stoke'), 'get_homes');
	cmp_deeply ($league->{aways}->{Stoke}->{aways}, $league->get_aways ('Stoke'), 'get_aways');
	cmp_deeply ($league->{homes}->{Stoke}->{full_homes}, $league->get_full_homes ('Stoke'), 'get_full_homes');
	cmp_deeply ($league->{aways}->{Stoke}->{full_aways}, $league->get_full_aways ('Stoke'), 'get_full_aways');
};

# Football_IO_Role
subtest 'append_prev' => sub {
	plan tests => 1;
	my $file = $model->append_prev ('C:/Mine/perl/Football/benchtest/history/results.json');
	is ($file, 'C:/Mine/perl/Football/benchtest/history/results_prev.json', "append 'prev' to filename");
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

=head
subtest 'Goal Expect Model' => sub {
	plan tests => 6;

	my ($teams, $sorted) = $model->do_predict_models ($data->{by_match}, $leagues);
	isa_ok ($teams, 'HASH', '$teams');
	isa_ok ($sorted, 'HASH', '$sorted');

	is ($teams->{Stoke}->{av_home_for}, 1.33, 'Stoke - Average home for 1.33');
	is ($teams->{Stoke}->{av_home_against}, 1.83, 'Stoke - Average home against 1.83');
	is ($teams->{Stoke}->{av_away_for}, 1.17, 'Stoke - Average away for 1.17');
	is ($teams->{Stoke}->{av_away_against}, 2.17, 'Stoke - Average away against 2.17');
};
=cut
