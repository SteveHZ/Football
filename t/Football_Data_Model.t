#!	C:/Strawberry/perl/bin

#	Football_Data_Model.t 03/06/16

use strict;
use warnings;
use Test::More tests => 2;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Football::Football_Data_Model;

my $file = 'C:/Mine/perl/Football/data/E0.csv';

my $data_model = Football::Football_Data_Model->new ();

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($data_model, 'Football::Football_Data_Model', '$data_model');
};

subtest 'update' => sub {
	plan tests => 1;

	my $games = $data_model->update ($file);
	my $games_test = {
		home_team		=> re ('\w+'),
		away_team 		=> re ('\w+'),
		home_score 		=> re ('\d'),
		away_score 		=> re ('\d'),
		date 			=> re ('\d\d/\d\d/\d\d'),
	};

	cmp_deeply ($games, array_each ($games_test), "$file - all games match expected format");
};