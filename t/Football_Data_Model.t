#	Football_Data_Model.t 03/06/16, 19/01/19

use strict;
use warnings;
use Test::More tests => 5;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Football::Football_Data_Model;

my $test_path = 'C:/Mine/perl/Football/t/test data';
my $test_file = "$test_path/E0.csv";
my $csv_data_model = Football::Football_Data_Model->new ();
my $dbi_data_model = Football::Football_Data_Model->new (connect => 'dbi', path => $test_path);

subtest 'constructors' => sub {
	plan tests => 2;
	isa_ok ($csv_data_model, 'Football::Football_Data_Model', '$csv_data_model');
	isa_ok ($dbi_data_model, 'Football::Football_Data_Model', '$dbi_data_model');
};

subtest 'update' => sub {
	plan tests => 6;

	my $games = $csv_data_model->update ($test_file);

	is (@$games[0]->{home_team}, 'Arsenal', 'home team');
	is (@$games[1]->{away_team}, 'Man City', 'away team');
	is (@$games[2]->{home_score}, '2', 'home score');
	is (@$games[3]->{away_score}, '3', 'away score');
	is (@$games[4]->{date}, '12/08/17', 'date');

	my $games_rx = {
		home_team		=> re ('\w+'),
		away_team 		=> re ('\w+'),
		home_score 		=> re ('\d\d?'),
		away_score 		=> re ('\d\d?'),
		date 			=> re ('\d\d/\d\d/\d\d'),
	};
	cmp_deeply ($games, array_each ($games_rx), "$test_file - all games match expected format");
};

subtest 'read_csv' => sub {
	plan tests => 6;

	my $games = $csv_data_model->read_csv ($test_file);

	is (@$games[5]->{home_team}, 'Southampton', 'home team');
	is (@$games[6]->{away_team}, 'Liverpool', 'away team');
	is (@$games[7]->{home_score}, '1', 'home score');
	is (@$games[8]->{away_score}, '0', 'away score');
	is (@$games[9]->{date}, '13/08/17', 'date');

	my $games_rx = {
		home_team		=> re ('\w+'),
		away_team 		=> re ('\w+'),
		home_score 		=> re ('\d\d?'),
		away_score 		=> re ('\d\d?'),
		date 			=> re ('\d\d/\d\d/\d\d'),
	};
	cmp_deeply ($games, array_each ($games_rx), "$test_file - all games match expected format");
};

subtest 'dbi' => sub {
	plan tests => 4;

	my $results = $dbi_data_model->do_query ("SELECT * FROM E0 WHERE HOMETEAM = 'Stoke' AND FTHG > FTAG");

	is (@$results[0]->{date}, '19/08/17', 'date');
	is (@$results[1]->{awayteam}, 'Southampton', 'away team');
	is (@$results[2]->{fthg}, '2', 'home score');
	is (@$results[3]->{ftag}, '1', 'away score');
};

subtest 'remove apostrophes' => sub {
	plan tests => 1;
	my $test_file2 = "$test_path/E1.csv";
	my $games = $csv_data_model->read_csv ($test_file2);
	my $check = 1;

	for my $game (@$games) {
		$check = 0 if $game->{home_team} =~ /'/;
		$check = 0 if $game->{away_team} =~ /'/;
	}
	is ($check, 1, "removed apostrophes from $test_file2 ok");
};
