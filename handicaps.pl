#!	C:/Strawberry/perl/bin

#	handicaps.pl 09-11/04/17
#	v1.01 30/04/17 - 04/05/17

use strict;
use warnings;

use Rugby::Model;
use Rugby::Handicap_Model;
use Rugby::Spreadsheets::Handicap_View;

main ();

sub main {
	my $model = Rugby::Model->new ();

	my $games = $model->read_games ();
	my $leagues = $model->build_leagues ($games);
	my $handicaps = Rugby::Handicap_Model->new (leagues => $leagues);

	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $teams  = \% {$league->{teams}};
		my $team_list = \@ {$league->{team_list}};

		for my $team (@$team_list) {
		my $next = $teams->{$team}->iterator ();

			while ( my $game = $next->() ) {
				my ($for, $against) = split ('-', $game->{score});
				my $margin = $for - $against;
				$handicaps->update ($league_name, $team, $margin);
			}
		}
		my $view = Rugby::Spreadsheets::Handicap_View->new (league => $league_name);
		$view->write ($team_list, $handicaps);
	}
}
