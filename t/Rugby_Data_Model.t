#!	C:/Strawberry/perl/bin

#	Rugby_Data_Model.t 03/06/16, 02/07/17

use strict;
use warnings;
use Test::More tests => 2;
use Test::Deep;

use lib "C:/Mine/perl/Football";
use Rugby::Rugby_Data_Model;

my $file = 'C:/Mine/perl/Football/t/test_data/Super League results.csv';
my $games = {};
my $data_model = Rugby::Rugby_Data_Model->new ();

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($data_model, 'Rugby::Rugby_Data_Model', '$data_model');
};

subtest 'update' => sub {
	plan tests => 1;

	$data_model->update ($games, $file);
	my $games_test = {
		home_team		=> re ('\w+'),
		away_team 		=> re ('\w+'),
		home_score 		=> re ('\d'),
		away_score 		=> re ('\d'),
		date 			=> re ('\d\d/\d\d/\d\d'),
	};

	print "\n";
	cmp_deeply ( \@{ $games->{'Super League'} }, array_each ($games_test), "all games match expected format");
};