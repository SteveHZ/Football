#!	C:/Strawberry/perl/bin

#	goal_expect.pl 30/08/16 - 03/09/16
#	v1.1 07/09/16 (use GetOpt::Long)

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use Football::Model;
use Rugby::Model;
use Football::GoalExpect_Model;
use Football::GoalExpect_View;

main ();

sub main {
	my $sport = get_cmdline ();

	my $model = ($sport."::Model")->new ();
	my $expect = Football::GoalExpect_Model->new ();
#	my $expect_view = Football::GoalExpect_View->new ($sport);
	my $expect_view = Football::GoalExpect_View->new ( sport => $sport );
	
	my $games = $model->read_games ();
	my $leagues = $model->build_leagues ($games);
	
	my $home_table = $model->do_home_table ($games);
	my $away_table = $model->do_away_table ($games);
	
	my $homes = $model->homes ($leagues);
	my $aways = $model->aways ($leagues);

	my $fixture_list = $model->get_fixtures ();
	my $fixtures = $model->do_fixtures ($fixture_list, $homes, $aways);

	my ($teams, $sorted) = $expect->update ($leagues, $fixture_list);
	$expect_view->view ($leagues, $teams, $sorted);
}

sub get_cmdline {
	my $sport;

	GetOptions (
		'sport|r' => \$sport,
	) or die "Usage perl goal_expect.pl (-r)";

	return $sport ? "Rugby" : "Football";
}
