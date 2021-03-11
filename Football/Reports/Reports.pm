package Football::Reports::Reports;

# 	Football::Reports::Reports.pm 05/03/16
#	v2 12-13/04/16, 02/05/16
#	Mouse version 05/05/16


use MyLib qw(unique);
use Football::Utils qw(_get_all_teams);
use Football::Table;
use Football::Reports::LeaguePlaces;
use Football::Reports::GoalDifference;
use Football::Reports::Recent_GoalDifference;
use Football::Reports::HomeAwayDraws;

use Moo;
use namespace::clean;

with 'Roles::MyJSON';

has 'recent_goal_diff' => ( is => 'ro');
has 'goal_diff' => ( is => 'ro');
has 'league_places' => ( is => 'ro');
has 'home_away_draws' => ( is => 'ro');

my $historical_path = 'C:/Mine/perl/Football/data/historical/';

sub BUILD {
	my ($self, $args) = @_;

	$self->{recent_goal_diff} =
		Football::Reports::Recent_GoalDifference->new (
			leagues => $args->{leagues}
		);
	$self->{goal_diff} =
		Football::Reports::GoalDifference->new (
			leagues => $args->{leagues}
		);
	$self->{league_places} =
		Football::Reports::LeaguePlaces->new (
			leagues => $args->{leagues},
			league_size => $args->{league_size}
		);
	$self->{home_away_draws} =
		Football::Reports::HomeAwayDraws->new (
			leagues => $args->{leagues},
			seasons => $args->{seasons}
		);
}

sub run {
	my ($self, $leagues, $seasons) = @_;

	print "\n\n";
	for my $league (@$leagues) {
		for my $season ( $seasons->{$league}->@* ) {
			print "\nReports - Updating $league - $season...";

			my $json_file = $historical_path.$league.'/'.$season.'.json';
			my $games = $self->read_json ($json_file);
			my $season_teams = get_all_teams ($games);
			my $table = Football::Table->new (
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
				if ($week > 6) {
					$_->update ($league, $teams, $game, $season) for values (%$self);
				}
				$table->update ($game);
			}
		}
	}
	$_->write ($leagues) for values (%$self);
}

sub get_all_teams {
	my $games = shift;
	return _get_all_teams ($games, "home_team");
}

1;
