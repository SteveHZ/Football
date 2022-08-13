package Football::Reports::GoalDifference;

# 	Football::Reports::GoalDifference.pm 05/03/16 - 13/04/16
#	v1.1 06-08/05/17

use Football::Spreadsheets::Reports;
use Moo;
use namespace::clean;

extends 'Football::Reports::Base';

sub BUILD {
	my ($self, $args) = @_;

	$self->{json_file} = $self->get_json_file ();
	( $self->{min}, $self->{max} ) = $self->get_minmax ();
	if ($args->{leagues}) {
		$self->{hash} = $self->setup ($args->{leagues});
	} else {
		$self->{hash} = $self->read_json ($self->{json_file});
	}
}

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data';
	return "$path/goal_diff.json";
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
	my $home_diff = $teams->{$home}->{goal_diff};
	my $away_diff = $teams->{$away}->{goal_diff};
	my $goal_diff = $home_diff - $away_diff;
	$goal_diff = $self->do_limits ($goal_diff) if abs $goal_diff > $self->{max};

	if ($result eq 'H')		{ $self->{hash}->{$league}->{$goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$goal_diff}->{draw} ++; }
}

sub write_report {
	my ($self, $leagues) = @_;

	my $writer = Football::Spreadsheets::Reports->new (
		report => 'Goal Difference',
		size => $self->{max},
	);
	$writer->do_goal_difference ($self->{hash}, $leagues);
}

sub fetch_array {
	my ($self, $league, $goal_diff) = @_;
	$goal_diff = $self->do_limits ($goal_diff) if abs $goal_diff > $self->{max};

	return [
		$self->{hash}->{$league}->{$goal_diff}->{home_win},
		$self->{hash}->{$league}->{$goal_diff}->{away_win},
		$self->{hash}->{$league}->{$goal_diff}->{draw},
	];
}

sub fetch_hash {
	my ($self, $league, $goal_diff) = @_;
	$goal_diff = $self->do_limits ($goal_diff) if abs $goal_diff > $self->{max};
	return $self->{hash}->{$league}->{$goal_diff};
}

sub do_limits {
	my ($self, $goal_diff) = @_;
	return ($goal_diff > 0) ? $self->{max} : $self->{min};
}

1;
