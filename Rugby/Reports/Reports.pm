package Rugby::Reports::Reports;

# 	Rugby::Reports::Reports.pm 05/03/16
#	v1.1 07/05/18

use MyLib qw(unique);
use Football::Utils qw(_get_all_teams);
use Rugby::Table;
use Rugby::Reports::LeaguePlaces;
use Rugby::Reports::GoalDifference;
use Rugby::Reports::Recent_GoalDifference;
use Rugby::Reports::HomeAwayDraws;

use Moo;
use namespace::clean;

with 'Roles::MyJSON';

sub BUILD {
	my ($self, $args) = @_;

	$self->{recent_goal_diff} =
		Rugby::Reports::Recent_GoalDifference->new (
			leagues => $args->{leagues}
		);
	$self->{goal_diff} =
		Rugby::Reports::GoalDifference->new (
			leagues => $args->{leagues}
		);
	$self->{league_places} =
		Rugby::Reports::LeaguePlaces->new (
			leagues => $args->{leagues},
			league_size => $args->{league_size}
		);
	$self->{home_away_draws} =
		Rugby::Reports::HomeAwayDraws->new (
			leagues => $args->{leagues},
			seasons => $args->{seasons}
		);
}

sub run {
	my ($self, $leagues, $seasons) = @_;
	my $historical_path = 'C:/Mine/perl/Football/data/Rugby/historical/';

	print "\n\n";
	for my $league (@$leagues) {
		for my $season (@{ $seasons->{$league} }) {
			print "\nReports - Updating $league - $season...";

			my $json_file = $historical_path.$season.'/'.$league.'.json';
			my $games = $self->read_json ($json_file);
			my $season_teams = get_all_teams ($games);
			my $table = Rugby::Table->new (
				teams => $season_teams
			);
			my $teams = {};
			my $week = 0;

			for my $game (@$games) {
				if ($game->{week} > $week) {
					$week ++;
					my $idx = 1;
					my $sorted = $table->sort_table ();
					for my $team (@$sorted) {
						my $name = $team->{team};
						$teams->{$name}->{position} = $idx ++;
						$teams->{$name}->{goal_diff} = $table->goal_diff ($name);
						$teams->{$name}->{recent_goal_diff} = $table->recent_goal_diff ($name);
					}
				}
				if ($week > 6) { # need to not update above lines as well ??
					for my $report (values %$self) {
						$report->update ($league, $teams, $game, $season);
					}
				}
				$table->update ($game);
			}
		}
	}

	for my $report (values %$self) {
		$report->write ($leagues);
	}
}

sub get_all_teams {
	my $games = shift;
	return _get_all_teams ($games, "home_team");
}

1;