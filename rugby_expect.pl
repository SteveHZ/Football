#!	C:/Strawberry/perl/bin

#	rugby_expect.pl 30/08/16 - 03/09/16

use strict;
use warnings;

use Rugby::Model;
use Football::GoalExpect_Model;
use Football::GoalExpect_View;

main ();

sub main {
	my $model = Rugby::Model->new ();
	my $expect = Football::GoalExpect_Model->new ();
	my $expect_view = Football::GoalExpect_View->new ();
	
	my $games = $model->read_games ();
	my $leagues = $model->build_leagues ($games);
	
	my $home_table = $model->do_home_table ($games);
	my $away_table = $model->do_away_table ($games);
	
	my $homes = $model->homes ($leagues);
	my $aways = $model->aways ($leagues);

	my $fixture_list = $model->get_fixtures ();
	my $fixtures = $model->do_fixtures ($fixture_list, $homes, $aways);

	my ($data, $sorted) = $expect->update ($leagues, $fixture_list);
	$expect_view->view ($leagues, $data, $sorted);
}
