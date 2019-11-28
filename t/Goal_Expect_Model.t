#	Goal_Expect_Model.t 14/09/16, 20/01/19

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; }

use strict;
use warnings;
use Test::More tests => 3;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Predictions::Model;
use Football::Game_Predictions::Goal_Expect_Model;
use Data::Dumper;

my $model = Football::Model->new ();
my ($data, $stats) = $model->quick_build ();

my $predict_model = Football::Game_Predictions::Model->new (
	leagues => $data->{leagues},
	fixtures => $stats->{by_match},
);

my $expect_model = Football::Game_Predictions::Goal_Expect_Model->new (
	leagues => $data->{leagues},
	fixtures => $stats->{by_match},
);

subtest 'Constructors' => sub {
	plan tests => 3;
	isa_ok ($model, 'Football::Model', '$model');
	isa_ok ($predict_model, 'Football::Game_Predictions::Model', '$predict_model');
	isa_ok ($expect_model, 'Football::Game_Predictions::Goal_Expect_Model', '$expect_model');
};

subtest 'get_average' => sub {
	plan tests => 1;
	my $list = [ qw( Stoke Vale Crewe Leek ) ];
	is ($expect_model->get_average (24, $list), '6.00', 'get_average');
};

subtest 'goal_expect' => sub {
	plan tests => 12;
	my ($teams, $sorted) = $predict_model->calc_goal_expect ();

	is ($teams->{Stoke}->{av_home_for}, 1.33, 'av home for');
	is ($teams->{Stoke}->{av_home_against}, 1.83, 'av home against');
	is ($teams->{Stoke}->{av_away_for}, 1.17, 'av away for');
	is ($teams->{Stoke}->{av_away_against}, 2.17, 'av away against');

	is ($teams->{Stoke}->{expect_home_for}, '0.90', 'expect home for');
	is ($teams->{Stoke}->{expect_home_against}, 1.61, 'expect home against');
	is ($teams->{Stoke}->{expect_away_for}, 1.03, 'expect away for');
	is ($teams->{Stoke}->{expect_away_against}, 1.47, 'expect away against');

	is ($teams->{Stoke}->{last_six_for}, 10, 'last_six for');
	is ($teams->{Stoke}->{last_six_against}, 14, 'last_six against');
	is ($teams->{Stoke}->{av_last_six_for}, 1.66666666666667, 'av last_six for');
	is ($teams->{Stoke}->{av_last_six_against}, 2.33333333333333, 'av last_six against');
};
