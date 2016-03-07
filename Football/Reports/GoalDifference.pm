package Football::Reports::GoalDifference;

# 	Football::Reports::GoalDifference.pm 05/03/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Spreadsheets::Reports;

use parent 'Football::Reports::Base';

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'goal_diff.json';

sub new {
	my ($class, $seasons) = @_;
	
	my $self = $class->SUPER::new ($json_file);
	if ($seasons) {
		$self->{hash} = $self->setup ();
	} else {
		$self->{hash} = read_json ($json_file);
	}
	bless $self, $class;
	return $self;
}

sub setup {
	my $self = shift;
	my $hash = {};
	for my $goal_diff (-100..100) {
		$hash->{$goal_diff} = $self->setup_results ();
	}
	return $hash;
}

sub update {
	my ($self, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_diff = $teams->{$home}->{goal_diff};
	my $away_diff = $teams->{$away}->{goal_diff};
	my $goal_diff = $home_diff - $away_diff;
	
	if ($result eq 'H')		{ $self->{hash}->{$goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$goal_diff}->{draw} ++; }
}

sub write_report {
	my $self = shift;
	
	my $writer = Football::Spreadsheets::Reports->new ("Goal Difference");
	$writer->do_goal_difference ($self->{hash});
}

sub fetch_array {
	my ($self, $goal_diff) = @_;
	return [
		$self->{hash}->{$goal_diff}->{home_win},
		$self->{hash}->{$goal_diff}->{away_win},
		$self->{hash}->{$goal_diff}->{draw},
	];
}

sub fetch_hash {
	my ($self, $goal_diff) = @_;
	return \%{ $self->{hash}->{$goal_diff} };
}

1;