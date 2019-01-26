#	Over_Under_Model.t 23/05/18

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; }

use strict;
use warnings;
use Test::More tests => 3;
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;
use MyJSON qw(read_json);

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

subtest 'do_calcs' => sub {
	my $test_data = read_json ('C:/Mine/perl/Football/t/test data/ou_points data.json');
	my $burnley = $test_data->{Burnley};
	my $arsenal = $test_data->{Arsenal};
	my $palace = $test_data->{'Crystal Palace'};
	my $stoke = $test_data->{Stoke};

	is ( $ou_model->do_calcs ([ @$burnley, @$arsenal ]), -1.5, 'Burnley v Arsenal = -1.5' );
	is ( $ou_model->do_calcs ([ @$palace, @$stoke ]), 2.5, 'CPalace v Stoke = 2.5' );
};

subtest 'over under' => sub {
	plan tests => 6;
	my ($teams, $sorted) = $model->do_predict_models ($stats->{by_match}, $data->{leagues});

	my $game = @{ $sorted->{over_under}->{ou_points} }[0];
	is ($game->{home_team}, 'Aston Villa', 'home team');
	is ($game->{away_team}, 'Ipswich', 'away team');
	is ($game->{ou_points}, 6, 'ou points');

	$game = @{ $sorted->{over_under}->{ou_points} }[1];
	is ($game->{home_team}, 'Reading', 'home team');
	is ($game->{away_team}, 'Sheffield Weds', 'away team');
	is ($game->{ou_points}, 5, 'ou points');
};
