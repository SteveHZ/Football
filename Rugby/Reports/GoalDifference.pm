package Rugby::Reports::GoalDifference;

# 	Rugby::Reports::GoalDifference.pm 05/03/16
#	v1.1 06-08/05/17

use Rugby::Spreadsheets::Reports;
use Moo;
use namespace::clean;

extends 'Football::Reports::GoalDifference';

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/Rugby/';
	return $path.'goal_diff.json';
}

sub write_report {
	my ($self, $leagues) = @_;
	
	my $writer = Rugby::Spreadsheets::Reports->new (
		report => "Goal Difference",
		size => $self->{max},
	);
	$writer->do_goal_difference ($self->{hash}, $leagues);
}

sub update {
	my ($self, $league, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_diff = $teams->{$home}->{goal_diff};
	my $away_diff = $teams->{$away}->{goal_diff};
	my $goal_diff = int (($home_diff - $away_diff) / 10);
	
	if ($result eq 'H')		{ $self->{hash}->{$league}->{$goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$goal_diff}->{draw} ++; }
}

sub get_minmax {
	return (-100, 100);
}

1;