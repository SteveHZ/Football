package Football::View;

#	View.pm 03/02/16

use strict;
use warnings;
use v5.22; # for state

use Football::Spreadsheets::Teams;
use Football::Spreadsheets::Tables;
use Football::Spreadsheets::Predictions;

sub new {
	my $class = shift;
	my $self = {
		xlsx_teams => Football::Spreadsheets::Teams->new (),
		xlsx_tables => Football::Spreadsheets::Tables->new (),
		xlsx_predictions => Football::Spreadsheets::Predictions->new (),
	};

    bless $self, $class;
    return $self;
}

sub DESTROY {
	my $self = shift;
	$self->{xlsx_teams}->{workbook}->close ();	
	$self->{xlsx_tables}->{workbook}->close ();	
	$self->{xlsx_predictions}->{workbook}->close ();
}

sub print_all_games {
	my ($self, $games) = @_;
		
	for my $game (@$games) {
		state $count = 1;
		printf "\n%3d : %s %-15s %-15s %d-%d",	$count ++, $game->{date},
												$game->{home_team},  $game->{away_team},
												$game->{home_score}, $game->{away_score};
	
	}
}

sub homes {
	my ($self, $list) = @_;
	
	print "\n\nHomes :\n";
	for my $team (@$list) {
		printf "\n%-15s :", $team->{team};
		print " $_"  for (@{ $team->{homes}} );
	}
	$self->{xlsx_tables}->do_homes ($list, "Last Six Homes");
}

sub aways {
	my ($self, $list) = @_;
	
	print "\n\nAways :\n";
	for my $team (@$list) {
		printf "\n%-15s :", $team->{team};
		print " $_"  for (@{ $team->{aways}} );
	}
	$self->{xlsx_tables}->do_aways ($list, "Last Six Aways");
}

sub last_six {
	my ($self, $list) = @_;
	
	print "\n\nLast Six Games :\n";
	for my $team (@$list) {
		printf "\n%-15s :", $team->{team};
		print " $_"  for (@{ $team->{last_six}} );
	}
	$self->{xlsx_tables}->do_last_six ($list, "Last Six Games");
}

sub full_homes {
	my ($self, $list) = @_;
	
	for my $team (@$list) {
		print "\n\n$team->{team} :";
		for my $game (@{ $team->{homes}} ) {
			printf "\n%s : %-15s H %s  %s", $game->{date}, $game->{opponent},
											$game->{result}, $game->{score};
		}
	}
}

sub full_aways {
	my ($self, $list) = @_;
	
	for my $team (@$list) {
		print "\n\n$team->{team} :";
		for my $game (@{ $team->{aways}} ) {
			printf "\n%s : %-15s A %s  %s",	$game->{date}, $game->{opponent},
											$game->{result}, $game->{score};
		}
	}
}

sub do_teams {
	my ($self, $teams) = @_;
	my @sorted = sort { $a cmp $b } keys %$teams;
	
	for my $team (@sorted) {
		print "\n\n$team : $teams->{$team}->{position}";
		my $next = $teams->{$team}->iterator ();
		while (my $list = $next->()) {
			printf "\n%s : %-15s %s %-6s %s", $list->{date}, $list->{opponent},
											  $list->{home_away}, $list->{result}, $list->{score};
		}
	}
	$self->{xlsx_teams}->do_teams ($teams, \@sorted);
}

sub do_fixtures {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting home/away predictions...\n";
	for my $game (@$fixtures) {
		print "\n";
		print " $_"  for (@{ $game->{homes}} );
		printf "  %-15s v %-15s", $game->{home_team}, $game->{away_team};
		print " $_"  for (@{ $game->{aways}} );
		printf "  %2d-%d", $game->{home_points}, $game->{away_points};
	}
	print "\n";
	$self->{xlsx_predictions}->do_fixtures ($fixtures);
	$self->{xlsx_tables}->do_extended ($fixtures);
}

sub do_head2head {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting head to head predictions...\n";
	for my $game (@$fixtures) {
		print "\n";
		printf "%-15s v %-15s", $game->{home}, $game->{away};
		print " $_"  for (@{ $game->{head2head}} );
		printf "  %2d-%d", $game->{home_h2h}, $game->{away_h2h};
	}
	print "\n";
	$self->{xlsx_predictions}->do_head2head ($fixtures);
}

sub do_table {
	my ($self, $table) = @_;
	
	print "\n\nFull Table : \n\n";
	printf "%18s %2s %2s %2s %3s %3s %3s %2s",'P','W','L','D','F','A','GD','Pts';
	my $sorted = $table->sorted ();
	for my $team (@$sorted) {
		printf "\n%-15s %2d %2d %2d %2d %3d %3d %3d %3d",
			$team->{team}, $team->{played}, $team->{won}, $team->{lost},
			$team->{drawn}, $team->{for}, $team->{against},
			$team->{for} - $team->{against},
			$team->{points};
	}
	print "\n";
	$self->{xlsx_tables}->do_table ($table);
}

sub do_home_table {
	my ($self, $table) = @_;
	
	print "\n\nHome Table : \n\n";
	printf "%18s %2s %2s %2s %2s %2s %3s %2s",'P','W','L','D','F','A','GD','Pts';
	my $sorted = $table->sorted ();
	for my $team (@$sorted) {
		printf "\n%-15s %2d %2d %2d %2d %2d %2d %3d %3d",
			$team->{team}, $team->{played}, $team->{won}, $team->{lost},
			$team->{drawn}, $team->{for}, $team->{against},
			$team->{for} - $team->{against},
			$team->{points};
	}
	print "\n";
	$self->{xlsx_tables}->do_home_table ($table);
}

sub do_away_table {
	my ($self, $table) = @_;
	
	print "\n\nAway Table : \n\n";
	printf "%18s %2s %2s %2s %2s %2s %3s %2s",'P','W','L','D','F','A','GD','Pts';
	my $sorted = $table->sorted ();
	for my $team (@$sorted) {
		printf "\n%-15s %2d %2d %2d %2d %2d %2d %3d %3d",
			$team->{team}, $team->{played}, $team->{won}, $team->{lost},
			$team->{drawn}, $team->{for}, $team->{against},
			$team->{for} - $team->{against},
			$team->{points};
	}
	print "\n";
	$self->{xlsx_tables}->do_away_table ($table);
}

sub do_league_places {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting league places predictions...\n";
	for my $game (@$fixtures) {
		print "\n";
		printf "%-15s v %-15s", $game->{home}, $game->{away};
		printf "  %2d v %2d - Home Win : %2d Away Win : %2d Draw : %2d",
			$game->{home_pos},
			$game->{away_pos},
			$game->{results}[0],
			$game->{results}[1],
			$game->{results}[2];
	}
	print "\n";
	$self->{xlsx_predictions}->do_league_places ($fixtures);
}

sub do_goal_difference {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting goal difference predictions...\n";
	for my $game (@$fixtures) {
		print "\n";
		printf "%-15s v %-15s", $game->{home}, $game->{away};
		printf "  Goal Difference : %3d - Home Win : %2d Away Win : %2d Draw : %2d",
			$game->{goal_difference},
			$game->{results}[0],
			$game->{results}[1],
			$game->{results}[2];
	}
	print "\n";
	$self->{xlsx_predictions}->do_goal_difference ($fixtures);
}

sub do_recent_goal_difference {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting recent goal difference predictions...\n";
	for my $game (@$fixtures) {
		print "\n";
		printf "%-15s v %-15s", $game->{home}, $game->{away};
		printf "  Goal Difference : %3d - Home Win : %3d Away Win : %3d Draw : %3d",
			$game->{recent_goal_difference},
			$game->{results}[0],
			$game->{results}[1],
			$game->{results}[2];
	}
	print "\n";
	$self->{xlsx_predictions}->do_recent_goal_difference ($fixtures);
}

=head2

sub menu {
	print "\n1 = Update";
	print "\n2 = Read from JSON";
	print "\n9 = Quit";
	print "\n\n>";
	chomp (my $choice = <STDIN>);
	return $choice;
}

=cut

1;
