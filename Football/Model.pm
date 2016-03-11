package Football::Model;

#	Model.pm 03/02/16

use strict;
use warnings;
use v5.22; # for state

use MyJSON qw(read_json write_json);
use Football::Team;
use Football::Table;
use Football::HomeTable;
use Football::AwayTable;
use Football::Head2Head;
use Football::Reports::LeaguePlaces;
use Football::Reports::GoalDifference;
use Football::Reports::Recent_GoalDifference;

my $path = 'C:/Mine/perl/Football/data/';
my $premdata = $path.'E0.csv';
my $prem_file = $path.'prem 2015-16.json';
my $fixtures_file = $path.'fixtures.txt';

sub new {
	my $class = shift;
	my $self = {
		all_teams => [],
		table => [],
	};
	bless $self, $class;
	return $self;
}

sub all_teams {
	my $self = shift;
	return $self->{all_teams};
}

sub update {
	my ($date, $home, $away, $h, $a);
	my ($junk, @junk);
	my @list_games = ();

	print "\Updating...";
	open (my $fh, '<', $premdata) or die ("Can't find $premdata");
	my $line = <$fh>;
	while ($line = <$fh>) {
		($junk, $date, $home, $away, $h, $a, @junk) = split (/,/, $line);
		push ( @list_games, {
			date => $date,
			home_team => $home,
			away_team => $away,
			home_score => $h,
			away_score => $a,
		});
	}
	close $fh;
	write_json ($prem_file, \@list_games);
	return \@list_games;
}

sub read_teams {
	my $games = read_json ($prem_file);
	return $games;
}

sub get_all_teams {
	my ($self, $games) = @_;
	my @array = unique (
		db => $games,
		field => "home_team",
	);
	return \@array;
}	

sub build_teams {
	my ($self, $games) = @_;
	my $teams = {};
	
	$self->{all_teams} = $self->get_all_teams ($games);
	$self->{table} = Football::Table->new ($self->{all_teams});

	for my $team (@ {$self->all_teams ()} ) {
		$teams->{$team} = Football::Team->new ();
	}

	for my $game (@$games) {
		update_teams ($teams, $game);
		$self->{table}->update ($game);
	}
	my $sorted_table = $self->{table}->sort_table ();

	my $idx = 1;
	for my $sorted (@$sorted_table) {
		my $team = $sorted->{team};
		$teams->{$team}->{position} = $idx++;
	}

	return ($teams, $self->{table});
}

sub update_teams {
	my ($teams, $game) = @_;
	
	my $home_team = $game->{home_team};
	my $away_team = $game->{away_team};
	my ($home_result, $away_result) = get_result ($game->{home_score}, $game->{away_score});

	$teams->{$home_team}->add ( update_home ($game, $home_result));
	$teams->{$away_team}->add ( update_away ($game, $away_result));
}

sub get_result {
	my ($home, $away) = @_;
	return ('W','L') if $home > $away;
	return ('L','W') if $home < $away;
	return ('D','D');
}

sub update_home {
	my ($game, $home_result) = @_;
	return {
		date => $game->{date},
		opponent => $game->{away_team},
		home_away => 'H',
		result => $home_result,
		score => $game->{home_score}.'-'.$game->{away_score},
	};
}

sub update_away {
	my ($game, $away_result) = @_;
	return {
		date => $game->{date},
		opponent => $game->{home_team},
		home_away => 'A',
		result => $away_result,
		score => $game->{away_score}.'-'.$game->{home_score}
	};
}

sub homes {
	my ($self, $teams) = @_;
	
	my @list = ();
	for my $team (@ { $self->{all_teams} }) {
		my $stats = {};
		$stats->{team} = $team;
		$stats->{homes} = $teams->{$team}->get_homes ();
		$stats->{points} = get_points ($stats->{homes});
		push (@list, $stats);
	}
	return \@list;
}

sub aways {
	my ($self, $teams) = @_;
	
	my @list = ();
	for my $team (@ { $self->{all_teams} }) {
		my $stats = {};
		$stats->{team} = $team;
		$stats->{aways} = $teams->{$team}->get_aways ();
		push (@list, $stats);
	}
	return \@list;
}

sub get_points {
	my $stats = shift;
	my $points = { W => 3,D => 1,N => 1,L => 0,X => 0, };
	my $total = 0;
	
	for my $game (@$stats) {
		$total += $points->{$game};
	}
	return $total;
}

sub full_homes {
	my ($self, $teams) = @_;

	my @list = ();
	for my $team (@ { $self->{all_teams} }) {
		my $stats = {};
		$stats->{team} = $team;
		$stats->{homes} = $teams->{$team}->get_full_homes ();
		push (@list, $stats);
	}
	return \@list;
}
	
sub full_aways {
	my ($self, $teams) = @_;

	my @list = ();
	for my $team (@ { $self->{all_teams} }) {
		my $stats = {};
		$stats->{team} = $team;
		$stats->{aways} = $teams->{$team}->get_full_aways ();
		push (@list, $stats);
	}
	return \@list;
}

sub get_fixtures {
	my @fixtures = ();
	my ($home, $away);

	open (my $fh, '<', $fixtures_file);
	while (my $line = <$fh>) {
		chomp ($line);
		($home, $away) = split (/,/, $line);
		my $fixture = {
			home => $home,
			away => $away,
		};
		push (@fixtures, $fixture);
	}
	close $fh;
	my @sorted = sort { $a->{home} cmp $b->{home} } @fixtures;
	return \@sorted;

}

sub do_fixtures {
	my ($self, $teams, $fixtures) = @_;
	
	my @list = ();
	for my $game (@$fixtures) {
		my $stats = {};
		my $home = $game->{home};
		my $away = $game->{away};
		$stats->{home_team} = $home;
		$stats->{homes} = $teams->{$home}->get_homes ();
		$stats->{home_points} = get_points ($stats->{homes});
		$stats->{away_team} = $away;
		$stats->{aways} = $teams->{$away}->get_aways ();
		$stats->{away_points} = get_points ($stats->{aways});
		push (@list, $stats);
	}
	return \@list;
}

sub unique {
	my (%hash) = ( order => "asc", @_ );

	my $sort_func = ($hash{order} eq "asc") ?
		sub { $a cmp $b } : sub { $b cmp $a };

	return sort $sort_func
		keys %{{ map { $_->{$hash{field}}  => 1 } @{$hash{db}} }};
}

sub do_head2head {
	my ($self, $fixtures) = @_;
	my ($home, $away, $home_points, $away_points);
	
	my $h2h = Football::Head2Head->new ();
	for my $game (@$fixtures) {
		$home = $game->{home};
		$away = $game->{away};
		$game->{head2head} = $h2h->fetch ($home, $away);

		($home_points, $away_points) = h2h_points ($game->{head2head});
		$game->{home_h2h} = $home_points;
		$game->{away_h2h} = $away_points;
	}
	return $fixtures;
}

sub h2h_points {
	my $stats = shift;
	my ($home, $away) = (0,0);
	
	for my $result (@$stats) {
		if ($result eq 'H') 	{ $home += 3; }
		elsif ($result eq 'A') 	{ $away += 3; }
		elsif ($result ne 'X')	{ $home ++; $away ++; }
	}
	return ($home, $away);
}

sub do_home_table {
	my ($self, $games) = @_;
	my $table = Football::HomeTable->new ($self->{all_teams});
	
	for my $game (@$games) {
		$table->update ($game);
	}
	$table->sort_table ();
	return $table;
}

sub do_away_table {
	my ($self, $games) = @_;
	my $table = Football::AwayTable->new ($self->{all_teams});
	
	for my $game (@$games) {
		$table->update ($game);
	}
	$table->sort_table ();
	return $table;
}

sub do_league_places {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_points, $away_points);
	
	my $league_places = Football::Reports::LeaguePlaces->new ();
	for my $game (@$fixtures) {
		$home = $game->{home};
		$away = $game->{away};

		$game->{home_pos} = $teams->{$home}->{position};
		$game->{away_pos} = $teams->{$away}->{position};
		$game->{results} = $league_places->fetch_array ($game->{home_pos}, $game->{away_pos});
	}
	return $fixtures;
}

sub do_goal_difference {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_diff, $away_diff);
	
	my $goal_diff = Football::Reports::GoalDifference->new ();
	for my $game (@$fixtures) {
		$home = $game->{home};
		$away = $game->{away};

		$home_diff = $self->{table}->goal_diff ($home);
		$away_diff = $self->{table}->goal_diff ($away);
		$game->{goal_difference} = $home_diff - $away_diff;
		$game->{results} = $goal_diff->fetch_array ($game->{goal_difference});
	}
	return $fixtures;
}

sub do_recent_goal_difference {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_diff, $away_diff);
	
	my $goal_diff = Football::Reports::Recent_GoalDifference->new ();
	for my $game (@$fixtures) {
		$home = $game->{home};
		$away = $game->{away};

		$home_diff = $self->{table}->recent_goal_diff ($home);
		$away_diff = $self->{table}->recent_goal_diff ($away);
		$game->{recent_goal_difference} = $home_diff - $away_diff;
		$game->{results} = $goal_diff->fetch_array ($game->{recent_goal_difference});
	}
	return $fixtures;
}

1;
