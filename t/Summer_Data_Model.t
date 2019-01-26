#	Favourites_Data_Model.t 14/09/16
#	Euro_Data_Model.t 11/02/18
#	Summer::Summer_Data_Model.t 20/03/18

use strict;
use warnings;
use Test::More tests => 3;

use lib 'C:/Mine/perl/Football';
use Summer::Summer_Data_Model;

my $dir = 'test data/';
my $data_model = Summer::Summer_Data_Model->new ();

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($data_model, 'Summer::Summer_Data_Model', '$data_model');
};

subtest 'read euro' => sub {
	plan tests => 3;

	my $file = "$dir/IRL.csv";
	my $games = $data_model->read_data ($file);
	is (@$games[0]->{home_odds}, 9.8 , 'home odds ok');
	is (@$games[0]->{away_odds}, 1.3 , 'away odds ok');
	is (@$games[0]->{draw_odds}, 4.74, 'draw odds ok');
};

subtest 'read csv' => sub {
	plan tests => 3;

	my $file = "$dir/Irish.csv";
	my $games = $data_model->read_csv ($file);
	is (@$games[0]->{home_odds}, 3.69, 'home odds ok');
	is (@$games[0]->{away_odds}, 2.08, 'away odds ok');
	is (@$games[0]->{draw_odds}, 3.12, 'draw odds ok');
};
