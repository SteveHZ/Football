package Football::Reports::Recent_GoalDifference;

# 	Football::Reports::Recent_GoalDifference.pm 07/03/16 - 13/04/16
#	v1.1 07-08/05/17

use Football::Spreadsheets::Reports;
use Moo;
use namespace::clean;

extends 'Football::Reports::Base';

sub BUILD {
	my ($self, $args) = @_;

	$self->{json_file} = $self->get_json_file ();
	if ($args->{leagues}) {
		( $self->{min}, $self->{max} ) = $self->get_minmax ();
		$self->{hash} = $self->setup ($args->{leagues});
	} else {
		$self->{hash} = $self->read_json ($self->{json_file});
	}
}

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/';
	return $path.'recent_goal_diff.json';
}

sub get_minmax {
	return (-100, 100);
}

sub setup {
	my ($self, $leagues) = @_;

	my $hash = {};
	for my $league (@$leagues) {
		for my $goal_diff ( $self->{min}..$self->{max} ) {
			$hash->{$league}->{$goal_diff} = $self->setup_results ();
		}
	}
	return $hash;
}

sub update {
	my ($self, $league, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_diff = $teams->{$home}->{recent_goal_diff};
	my $away_diff = $teams->{$away}->{recent_goal_diff};
	my $recent_goal_diff = $home_diff - $away_diff;
	
	if ($result eq 'H')		{ $self->{hash}->{$league}->{$recent_goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$recent_goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$recent_goal_diff}->{draw} ++; }
}

sub write_report {
	my ($self, $leagues) = @_;
	
	my $writer = Football::Spreadsheets::Reports->new (
		report => "Recent Goal Difference",
		size => $self->{max},
	);
	$writer->do_recent_goal_diff ($self->{hash}, $leagues);
}

sub fetch_array {
	my ($self, $league, $goal_diff) = @_;
	return [
		$self->{hash}->{$league}->{$goal_diff}->{home_win},
		$self->{hash}->{$league}->{$goal_diff}->{away_win},
		$self->{hash}->{$league}->{$goal_diff}->{draw},
	];
}

sub fetch_hash {
	my ($self, $league, $goal_diff) = @_;
	return $self->{hash}->{$league}->{$goal_diff};
}

1;
