#!	C:/Strawberry/perl/bin

#	data_model_benchmark.pl 18/06/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Modules';
use lib 'C:/Mine/perl/Football';
use Football_Data_Model_Ex;
use Benchmark qw(:all);

my $data_model = Football_Data_Model_Ex->new ();

my $t = timethese ( -10, {
	"dbi" => sub {
		my $games = $data_model->update_dbi ("E0");
		return $games;
	},
	"csv" => sub {
		my $games = $data_model->update ("C:/Mine/perl/Football/data/E0.csv");
		return $games;
	},
});

cmpthese $t;
