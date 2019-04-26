package Rugby::Handicap;

#	Rugby::Handicap 09/04/17

use Moo;
use namespace::clean;

my $path = 'C:/Mine/perl/Football/Rugby/data/';
#my $json_file = $path.'handicap.json';

sub BUILD {
	my ($self, $args) = @_;

#	$self->{json_file} = $json_file;
	$self->{hash} = $self->setup ($args->{leagues});
}

sub setup {
	my ($self, $leagues) = @_;
	my $hash = {};

	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $league_ref = $hash->{$league_name};

		my $sorted = $league->{team_list};
		for my $team (@$sorted) {
			$league_ref->{$team} = $self->setup_handicaps ();
			$hash->{$league_name}->{$team} = $self->setup_handicaps ();
		}
	}
	return $hash;
}

sub setup_handicaps {
	my $hash = {};

	for (my $margin = 2; $margin <= 30; $margin += 2) {
		$hash->{$margin} = 0;
	}
	$hash->{games} = 0;
	return $hash;
}

sub update {
	my ($self, $league, $team, $win_margin) = @_;
	my $teamref = $self->{hash}->{$league}->{$team};

	if ($win_margin > 2) {
		for (my $margin = 2; $margin < $win_margin; $margin += 2) {
			$teamref->{$margin} ++
		}
	}
	$teamref->{games} ++;
}

=head
sub update {
	my ($self, $league, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_diff = $teams->{$home}->{goal_diff};
	my $away_diff = $teams->{$away}->{goal_diff};
	my $goal_diff = $home_diff - $away_diff;

	if ($result eq 'H')		{ $self->{hash}->{$league}->{$goal_diff}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$goal_diff}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$goal_diff}->{draw} ++; }
}

sub write_report {
	my ($self, $leagues) = @_;

	my $writer = Football::Spreadsheets::Reports->new (report => "Goal Difference");
	$writer->do_goal_difference ($self->{hash}, $leagues);
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
=cut
1;
