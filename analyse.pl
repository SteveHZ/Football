#	analyse.pl 26/01/19

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; }

use strict;
use warnings;
use Test::More tests => 1;
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;

my $ou_model;
my $model = Football::Model->new ();
my $data = $model->build_data ();

my $fixtures = $model->get_fixtures ();
my $stats = $model->do_fixtures ($fixtures, $data->{homes}, $data->{aways}, $data->{last_six});
my $predict_model = Football::Game_Prediction_Models->new (
	fixtures => $stats->{by_match},
	leagues => $data->{leagues},
);

subtest 'constructor' => sub {
	use_ok 'Football::Over_Under_Model';
	$ou_model = Football::Over_Under_Model->new (leagues => $data->{leagues}, fixtures => $fixtures, stats => $stats);
	isa_ok ($ou_model, 'Football::Over_Under_Model', '$ou_model');
	isa_ok ($predict_model, 'Football::Game_Prediction_Models', '$predict_model');
};
#<STDIN>;
print Dumper $fixtures;
