#	Goal_Expect_Model.t 14/09/16, 20/01/19

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; }

use strict;
use warnings;
use Test::More tests => 3;

use lib "C:/Mine/perl/Football";
use Football::Model;
use Football::Game_Prediction_Models;
use Football::Goal_Expect_Model;
use Data::Dumper;

my $model = Football::Model->new ();
my $predict_model = Football::Game_Prediction_Models->new ();
my $expect_model = Football::Goal_Expect_Model->new ();

subtest 'Constructors' => sub {
	plan tests => 3;
	isa_ok ($model, 'Football::Model', '$model');
	isa_ok ($predict_model, 'Football::Game_Prediction_Models', '$predict_model');
	isa_ok ($expect_model, 'Football::Goal_Expect_Model', '$expect_model');
};

subtest 'get_average' => sub {
	plan tests => 1;
	my $list = {
		'teams' => [ qw( Stoke Vale Crewe Leek ) ],
	};
	is ($expect_model->get_average (24, $list, 'teams'), '6.00', 'get_average');
};

subtest 'goal_expect' => sub {
	plan tests => 13;

	my $league_data = $model->build_data ();
	my $fixtures = $model->get_fixtures ();
	my $data = $model->do_fixtures ($fixtures, $league_data->{homes}, $league_data->{aways}, $league_data->{last_six});
	my ($teams, $sorted) = $predict_model->calc_goal_expect ($fixtures, $league_data->{leagues});

#	print Dumper $teams->{Stoke};
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

	print Dumper $sorted->{last_six}[0]; # to test goal diff routines in expect model / team_data
	my $game = $sorted->{last_six}[0]; # to test goal diff routines in expect model / team_data
=head
home_goals, 0.281792
away_goals, 2.347488
expected_goal_diff, -2.065696

home_last_six, 0.281792
away_last_six, 6.49686
expected_goal_diff_last_six -6.215068

home_goal_diff, -0.17
away_goal_diff, 2.17
home_away_goal_diff, -2.34

home_last_six_goal_diff, -1.83
away_last_six_goal_diff, 2.33
=cut
	is ($game->{last_six_goal_diff}, -4.16, 'last six goal diff');


};
