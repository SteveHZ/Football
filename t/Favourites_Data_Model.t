#!	C:/Strawberry/perl/bin

#	Favourites_Data_Model.t 14/09/16

use strict;
use warnings;
use Test::More tests => 3;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Football::Favourites_Data_Model;

my $file = 'test data/E0.csv';
my $file2 = 'test data/EC.csv';
my $file3 = 'test data/IRL.csv';
my $data_model = Football::Favourites_Data_Model->new ();

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($data_model, 'Football::Favourites_Data_Model', '$data_model');
};

subtest 'update current' => sub {
#	tests get_odds_cols in Football::Utils by testing
#	two files with odds in different columns
	plan tests => 6;

	my $games = $data_model->update_current ($file);
	is (@$games[0]->{home_odds}, 1.53, "home odds ok");
	is (@$games[0]->{away_odds}, 6.5,  "away odds ok");
	is (@$games[0]->{draw_odds}, 4.5,  "draw odds ok");

	$games = $data_model->update_current ($file2);
	is (@$games[0]->{home_odds}, 2.9,  "home odds ok");
	is (@$games[0]->{away_odds}, 2.38, "away odds ok");
	is (@$games[0]->{draw_odds}, 3.4,  "draw odds ok");
};

subtest 'update euro' => sub {
#	tests get_odds_cols in Football::Utils by testing
#	two files with odds in different columns
	plan tests => 3;

	my $games = $data_model->update_euro ($file3);
	is (@$games[0]->{home_odds}, 3.69, "home odds ok");
	is (@$games[0]->{away_odds}, 2.08, "away odds ok");
	is (@$games[0]->{draw_odds}, 3.12, "draw odds ok");
};