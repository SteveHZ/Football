package Rugby::Reports::Recent_GoalDifference;

# 	Rugby::Reports::Recent_GoalDifference.pm 07/03/16
#	v1.1 07-08/05/17

use Rugby::Spreadsheets::Reports;
use Moo;
use namespace::clean;

extends 'Football::Reports::Recent_GoalDifference';

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/Rugby/';
	return $path.'recent_goal_diff.json';
}

sub write_report {
	my ($self, $leagues) = @_;

	my $writer = Rugby::Spreadsheets::Reports->new (
		report => "Recent Goal Difference",
		size => $self->{max},
	);
	$writer->do_recent_goal_diff ($self->{hash}, $leagues);
}

sub update {
	my ($self, $league, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_diff = $teams->{$home}->{recent_goal_diff};
	my $away_diff = $teams->{$away}->{recent_goal_diff};
	my $recent_goal_diff = int (($home_diff - $away_diff) / 10);
	
	if ($result eq 'H')		{ $self->{hash}->{$league}->{$recent_goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$recent_goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$recent_goal_diff}->{draw} ++; }
}

sub get_minmax {
	return (-50, 50);
}

1;