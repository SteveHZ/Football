#	Over_Under_Model.t 23/05/18

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; }

use strict;
use warnings;
use Test::More tests => 4;
use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Predictions::Controller;
use MyJSON qw(read_json);

my $ou_model;
my $model = Football::Model->new ();
my ($data, $stats) = $model->quick_build ();

my $predict = Football::Game_Predictions::Controller->new (
	leagues => $data->{leagues},
	fixtures => $stats->{by_match},
	model_name => $model->model_name,
	type => 'season',
);

subtest 'constructor' => sub {
	plan tests => 3;

	use_ok 'Football::Game_Predictions::Over_Under_Model';
	$ou_model = Football::Game_Predictions::Over_Under_Model->new (
		leagues => $data->{leagues},
		fixtures => $stats->{by_match}
	);
	isa_ok ($ou_model, 'Football::Game_Predictions::Over_Under_Model', '$ou_model');
	isa_ok ($predict, 'Football::Game_Predictions::Controller', '$predict_model');
};

subtest 'do_calcs' => sub {
	plan tests => 2;

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
	my ($teams, $sorted) = $predict->do_predict_models ($stats->{by_match}, $data->{leagues});

	my $game = @{ $sorted->{over_under}->{ou_points} }[0];
	is ($game->{home_team}, 'Aston Villa', 'home team');
	is ($game->{away_team}, 'Ipswich', 'away team');
	is ($game->{ou_points}, 6, 'ou points');

	$game = @{ $sorted->{over_under}->{ou_points} }[1];
	is ($game->{home_team}, 'Reading', 'home team');
	is ($game->{away_team}, 'Sheffield Weds', 'away team');
	is ($game->{ou_points}, 5, 'ou points');
};

subtest 'unders' => sub {
	plan tests => 1;
	is (1,1,'ok');
	$ou_model->do_unders ();
}
