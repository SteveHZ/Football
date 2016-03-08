package Football::Reports::Recent_GoalDifference;

# 	Football::Reports::Recent_GoalDifference.pm 07/03/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Spreadsheets::Reports;

use parent 'Football::Reports::Base';

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'/recent_goal_diff.json';

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
	for my $goal_diff (-30..30) {
		$hash->{$goal_diff} = $self->setup_results ();
	}
	return $hash;
}

sub update {
	my ($self, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_diff = $teams->{$home}->{recent_goal_diff};
	my $away_diff = $teams->{$away}->{recent_goal_diff};
	my $recent_goal_diff = $home_diff - $away_diff;
	
	if ($result eq 'H')		{ $self->{hash}->{$recent_goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$recent_goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$recent_goal_diff}->{draw} ++; }
}

sub write_report {
	my $self = shift;
	
	my $writer = Football::Spreadsheets::Reports->new ("Recent Goal Difference");
	$writer->do_recent_goal_diff ($self->{hash});
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