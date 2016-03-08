package Football::Reports::Reports;

# 	Football::Reports::Reports.pm 05/03/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Model;
use Football::Table;
use Football::Reports::LeaguePlaces;
use Football::Reports::GoalDifference;
use Football::Reports::Recent_GoalDifference;

my $historical_path = 'C:/Mine/perl/Football/data/historical/';

sub new {
	my ($class, $seasons) = @_;
	
	my $self = {
		league_places => Football::Reports::LeaguePlaces->new ($seasons),
		goal_diff => Football::Reports::GoalDifference->new ($seasons),
		recent_goal_diff => Football::Reports::Recent_GoalDifference->new ($seasons),
	};

	bless $self, $class;
	return $self;
}

sub run {
	my ($self, $seasons) = @_;
	my $hash = {};
	my $model = Football::Model->new ();
	
	print "\n";
	for my $season (@{ $seasons->{all_seasons} }) {
		print "\nUpdating $season...";

		my $json_file = $historical_path.$season.'.json';
		my $games = read_json ($json_file);
		my $all_teams = $model->get_all_teams ($games);
		my $table = Football::Table->new ($all_teams);
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
#if ($week > 6) {
			$_->update ($teams, $game) for values (%$self);
#}
			$table->update ($game);
		}
	}
	$_->write () for values (%$self);
	return $hash;
}

1;