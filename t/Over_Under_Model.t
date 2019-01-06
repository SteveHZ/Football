#	Over_Under_Model.t 23/05/18

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; }

use strict;
use warnings;
use Data::Dumper;

use Football::Model;
use MyJSON qw(read_json);
use Test::More tests => 2;
use lib "C:/Mine/perl/Football";

my $ou_model;
my $model = Football::Model->new ();
my $games = $model->read_games ();
my $leagues = $model->build_leagues ($games);

my $homes = $model->do_homes ($leagues);
my $aways = $model->do_aways ($leagues);
my $last_six = $model->do_last_six ($leagues);
my $league_array = \@{ $model->{leagues} };

my $fixtures = $model->get_fixtures ();
my $stats = $model->do_fixtures ($fixtures, $homes, $aways, $last_six);

subtest 'constructor' => sub {
	use_ok 'Football::Over_Under_Model';
	$ou_model = Football::Over_Under_Model->new (leagues => $leagues, fixtures => $fixtures, stats => $stats);
	isa_ok ($ou_model, 'Football::Over_Under_Model', '$ou_model');
};

subtest 'do_calcs' => sub {
	my $test_data = read_json ('C:/Mine/perl/Football/t/test data/ou_points data.json');
	my $burnley = $test_data->{Burnley};
	my $arsenal = $test_data->{Arsenal};
	my $palace = $test_data->{'Crystal Palace'};
	my $stoke = $test_data->{Stoke};

	is ( $ou_model->do_calcs ([ @$burnley, @$arsenal ]), -1.5, 'Burnley v Arsenal = -1.5' );
	is ( $ou_model->do_calcs ([ @$palace, @$stoke ]), 2.5, 'CPalace v Stoke = 2.5' );
};
