#!	C:/Strawberry/perl/bin

#	football.pl 31/01 - 21/02/16

use strict;
use warnings;

use Football::Model;
use Football::View;

main ();

sub main {
	my $model = Football::Model->new ();
	my $view = Football::View->new ();

	my $arg = $ARGV[0] // "";
	my $games = ($arg eq "-u") ? $model->update () :
								 $model->read_teams ();
								 
	my ($teams, $table) = $model->build_teams ($games);
	$view->do_teams ($teams);
	$view->do_table ($table);

	$view->do_home_table ( $model->do_home_table ($games));
	$view->do_away_table ( $model->do_away_table ($games));

#<STDIN>;	
	$view->homes ( $model->homes ($teams) );
#<STDIN>;	
	$view->aways ( $model->aways ($teams) );
#<STDIN>;	
	$view->last_six ( $model->last_six ($teams) );
#<STDIN>;	
	$view->full_homes ( $model->homes ($teams) );
#<STDIN>;
	$view->full_aways ( $model->aways ($teams) );
#<STDIN>;	

	my $fixtures = $model->get_fixtures ();
	$view->do_fixtures ( $model->do_fixtures ($teams, $fixtures) );
	$view->do_head2head ( $model->do_head2head ($fixtures));
	$view->do_league_places ( $model->do_league_places ($fixtures, $teams));
	$view->do_goal_difference ( $model->do_goal_difference ($fixtures, $teams));
	$view->do_recent_goal_difference ( $model->do_recent_goal_difference ($fixtures, $teams));
}
