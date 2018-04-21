package Football::View;

#	Football::View.pm 03/02/16, Mouse version 04/05/16
#	Moo version 01/10/16
#	v1.1 05-06/05/17

use Football::Spreadsheets::Teams;
use Football::Spreadsheets::Tables;
use Football::Spreadsheets::Predictions;
use Football::Spreadsheets::Extended;
use Football::Spreadsheets::Favourites;
use Football::Spreadsheets::Goal_Expect_View;
use Football::Spreadsheets::Goal_Diffs_View;
use Football::Spreadsheets::Match_Odds_View;
use Football::Spreadsheets::Over_Under_View;
use Football::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;
	$self->create_sheets ();
	$self->get_formats ();	
}

sub DEMOLISH {
	my $self = shift;
	$self->destroy_sheets ();
}

sub create_sheets {
	my $self = shift;

	$self->{xlsx_predictions} = Football::Spreadsheets::Predictions->new ();
	$self->{xlsx_extended} = Football::Spreadsheets::Extended->new ();
	$self->{xlsx_favourites} = Football::Spreadsheets::Favourites->new (filename => 'current');
	$self->{xlsx_goal_expect} = Football::Spreadsheets::Goal_Expect_View->new ();
	$self->{xlsx_goal_diffs} = Football::Spreadsheets::Goal_Diffs_View->new ();
	$self->{xlsx_match_odds} = Football::Spreadsheets::Match_Odds_View->new ();
	$self->{xlsx_over_under} = Football::Spreadsheets::Over_Under_View->new ();
	$self->{xlsx_skellam} = Football::Spreadsheets::Skellam_Dist_View->new ();
}

sub destroy_sheets {
	my $self = shift;

	$self->{xlsx_teams}->{$_}->{workbook}->close () for keys %{ $self->{xlsx_teams}};	
	$self->{xlsx_tables}->{$_}->{workbook}->close () for keys %{ $self->{xlsx_tables}};	
	$self->{xlsx_predictions}->{workbook}->close ();
	$self->{xlsx_extended}->{workbook}->close ();
	$self->{xlsx_favourites}->{workbook}->close ();
	$self->{xlsx_goal_expect}->{workbook}->close ();
	$self->{xlsx_goal_diffs}->{workbook}->close ();
	$self->{xlsx_match_odds}->{workbook}->close ();
	$self->{xlsx_over_under}->{workbook}->close ();
	$self->{xlsx_skellam}->{workbook}->close ();
}

sub create_new_teams_sheet {
	my ($self, $filename) = @_;
	return Football::Spreadsheets::Teams->new (filename => $filename);
}

sub create_new_tables_sheet {
	my ($self, $filename) = @_;
	return Football::Spreadsheets::Tables->new (filename => $filename);
}

sub do_teams {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $teams  = \% {$league->{teams}};
		my $sorted = \@ {$league->{team_list}};
		
		for my $team (@$sorted) {
			print "\n\n$team : $teams->{$team}->{position} ( $league->{title} )";
#			my $next = $teams->{$team}->iterator ();
			if ( my $next = $teams->{$team}->iterator () ) {
				while ( my $list = $next->() ) {
					printf $self->{teams_format}, $list->{date}, $list->{opponent},
												  $list->{home_away}, $list->{result}, $list->{score};
				}
			}
		}
		$self->{xlsx_teams}->{$league_name} = $self->create_new_teams_sheet ($league_name);
		$self->{xlsx_teams}->{$league_name}->do_teams ($teams, $sorted);
	}
}

sub do_table {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $table = $league->{table}->sorted;
	
		print "\n\n$league_name Full Table : \n\n";
		printf $self->{table_format}, @{ $self->{table_header} };
		for my $team (@$table) {
			printf $self->{main_table_format},
				$team->{team}, $team->{played}, $team->{won}, $team->{lost},
				$team->{drawn}, $team->{for}, $team->{against},
				$team->{for} - $team->{against},
				$team->{points};
		}
		print "\n";
		$self->{xlsx_tables}->{$league_name} = $self->create_new_tables_sheet ($league_name);
		$self->{xlsx_tables}->{$league_name}->do_table ($table)
	}
}

sub do_home_table {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $table = $league->{home_table}->sorted ();

		print "\n\n$league_name Home Table : \n\n";
		printf $self->{table_format}, @{ $self->{table_header} };
		for my $team (@$table) {
			printf $self->{main_table_format},
				$team->{team}, $team->{played}, $team->{won}, $team->{lost},
				$team->{drawn}, $team->{for}, $team->{against},
				$team->{for} - $team->{against},
				$team->{points};
		}
		print "\n";
		$self->{xlsx_tables}->{$league_name}->do_home_table ($table);
	}
}

sub do_away_table {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $table = $league->{away_table}->sorted ();

		print "\n\n$league_name Away Table : \n\n";
		printf $self->{table_format}, @{ $self->{table_header} };
		for my $team (@$table) {
			printf $self->{main_table_format},
				$team->{team}, $team->{played}, $team->{won}, $team->{lost},
				$team->{drawn}, $team->{for}, $team->{against},
				$team->{for} - $team->{against},
				$team->{points};
		}
		print "\n";
		$self->{xlsx_tables}->{$league_name}->do_away_table ($table);
	}
}

sub homes {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $list = $league->{homes};
	
		print "\n\n$league_name Homes :\n";
		for my $team (keys %$list) {
			printf $self->{homes_format}, $list->{$team}->{name};
			print " $_"  for (@{ $list->{$team}->{homes}} );
		}
		$self->{xlsx_tables}->{$league_name}->do_homes ($list, "Last Six Homes");
	}
}

sub aways {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $list = $league->{aways};
	
		print "\n\n$league_name Aways :\n";
		for my $team (keys %$list) {
			printf $self->{homes_format}, $list->{$team}->{name};
			print " $_"  for (@{ $list->{$team}->{aways}} );
		}
		$self->{xlsx_tables}->{$league_name}->do_aways ($list, "Last Six Aways");
	}
}

sub last_six {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $list = $league->{last_six};
		
		print "\n\n$league_name Last Six Games :\n";
		for my $team (keys %$list) {
			printf $self->{homes_format}, $list->{$team}->{name};
			print " $_"  for (@{ $list->{$team}->{last_six}} );
		}
		$self->{xlsx_tables}->{$league_name}->do_last_six ($list, "Last Six Games");
	}
}

sub full_homes {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $list = $league->{homes};
	
		for my $team (keys %$list) {
			print "\n\n$list->{$team}->{name} :";
			for my $game (@{ $list->{$team}->{full_homes}} ) {
				printf $self->{full_homes_format},
					$game->{date}, $game->{opponent},
					$game->{result}, $game->{score};
			}
		}
	}
}

sub full_aways {
	my ($self, $leagues) = @_;
	
	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $list = $league->{aways};
	
		for my $team (keys %$list) {
			print "\n\n$list->{$team}->{name} :";
			for my $game (@{ $list->{$team}->{full_aways}} ) {
				printf $self->{full_aways_format},
					$game->{date}, $game->{opponent},
					$game->{result}, $game->{score};
			}
		}
	}
}

#=head
sub fixtures {
	my ($self, $fixtures) = @_;

	print "\n\nWriting fixtures...\n";
	for my $game (@$fixtures) {
		print "\n$game->{league_idx} $game->{league} $game->{home_team} v $game->{away_team}";
	}
}

sub do_fixtures {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting home/away predictions...\n";
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		print "\n\n$league_name :";
		for my $game (@{ $league->{games} }) {
			print "\n";
			print " $_"  for (@{ $game->{homes}} );
			printf $self->{fixtures_format}, $game->{home_team}, $game->{away_team};
			print " $_"  for (@{ $game->{aways}} );
			printf $self->{fixtures_format2}, $game->{home_points}, $game->{away_points};
			printf "  %2d-%d", $game->{home_points}, $game->{away_points};
		}
	}
	print "\n";
	$self->{xlsx_predictions}->do_fixtures ($fixtures);
	$self->{xlsx_predictions}->do_last_six ($fixtures);
	$self->{xlsx_extended}->do_extended ($fixtures);
}

sub do_head2head {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting head to head predictions...\n";
	for my $league (@$fixtures) {
		print "\n\n$league->{league} :";
		for my $game (@{ $league->{games} }) {
			print "\n";
			printf $self->{league_places_format}, $game->{home_team}, $game->{away_team};
			print " $_"  for (@{ $game->{head2head}} );
			printf $self->{fixtures_format2}, $game->{home_h2h}, $game->{away_h2h};
		}
	}
	print "\n";
	$self->{xlsx_predictions}->do_head2head ($fixtures);
}

sub do_league_places {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting league places predictions...\n";
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		print "\n$league_name";

		for my $game (@{ $league->{games}}) {
			print "\n";
			printf $self->{league_places_format}, $game->{home_team}, $game->{away_team};
			printf $self->{league_places_format2},
				$game->{home_pos},
				$game->{away_pos},
				$game->{results}[0],
				$game->{results}[1],
				$game->{results}[2];
		}
		print "\n";
	}
	$self->{xlsx_predictions}->do_league_places ($fixtures);
}

sub do_recent_goal_difference {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting recent goal difference predictions...\n";
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		print "\n$league_name";

		for my $game (@{ $league->{games}}) {
			print "\n";
			printf $self->{league_places_format}, $game->{home_team}, $game->{away_team};
			printf $self->{goal_diff_format},
				$game->{recent_goal_difference},
				$game->{rgd_results}[0],
				$game->{rgd_results}[1],
				$game->{rgd_results}[2];
		}
		print "\n";
	}
	$self->{xlsx_predictions}->do_recent_goal_difference ($fixtures);
}

sub do_goal_difference {
	my ($self, $fixtures) = @_;
	
	print "\n\nWriting goal difference predictions...\n";
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		print "\n$league_name";

		for my $game (@{ $league->{games}}) {
			print "\n";
			printf $self->{league_places_format}, $game->{home_team}, $game->{away_team};
			printf $self->{goal_diff_format},
				$game->{goal_difference},
				$game->{gd_results}[0],
				$game->{gd_results}[1],
				$game->{gd_results}[2];
		}
		print "\n";
	}
	$self->{xlsx_predictions}->do_goal_difference ($fixtures);
}

sub do_recent_draws {
	my ($self, $draws) = @_;
	
	print "\n\nWriting recent draw predictions...\n";
	for my $game (@$draws) {
		print "\n";
		printf $self->{recent_draws_format}, $game->{game}->{draws}, $game->{game}->{home_team}, $game->{game}->{away_team};
		printf $self->{recent_draws_format2}, $game->{game}->{home_draws}, $game->{game}->{away_draws}, $game->{league};
	}
	print "\n";
	$self->{xlsx_predictions}->do_recent_draws ($draws);
}
#=cut

sub do_favourites {
	my ($self, $hash) = @_;
	$self->{xlsx_favourites}->do_favourites ($hash);
}

#=head
sub do_goal_expect {
	my ($self, $leagues, $teams, $sorted, $fixtures) = @_;

	$self->{xlsx_goal_expect}->view ($leagues, $teams, $sorted->{expect});
	$self->{xlsx_goal_diffs}->view ($sorted);
}

sub do_match_odds {
	my ($self, $sorted) = @_;
	
	$self->{xlsx_skellam}->view ($sorted->{skellam});
	$self->{xlsx_match_odds}->view ($sorted->{match_odds});
}

sub do_over_under {
	my ($self, $sorted) = @_;
	$self->{xlsx_over_under}->view ($sorted->{over_under});
}
#=cut

sub get_formats {
	my $self = shift;

	$self->{table_format} = "%21s %2s %2s %2s %3s %3s %3s %2s";
	$self->{table_header} = [ qw (P W L D F A GD Pts) ];
	$self->{main_table_format} = "\n%-18s %2d %2d %2d %2d %3d %3d %3d %3d";
	$self->{teams_format} = "\n%s : %-18s %s %-6s %s";
	$self->{homes_format} = "\n%-18s :";
	$self->{full_homes_format} = "\n%s : %-18s H %s  %s";
	$self->{full_aways_format} = "\n%s : %-18s A %s  %s";
	$self->{fixtures_format} = "\t%-18s v %-18s";
	$self->{fixtures_format2} = "  %2d-%d";

	$self->{league_places_format} = "%-18s v %-18s";
	$self->{league_places_format2} = "  %2d v %2d - Home Win : %2d Away Win : %2d Draw : %2d";
	$self->{recent_goal_diff_format} = "  Goal Difference : %3d - Home Win : %3d Away Win : %3d Draw : %3d";
	$self->{goal_diff_format} = "  Goal Difference : %3d - Home Win : %3d Away Win : %3d Draw : %3d";
	$self->{recent_draws_format} = "%d : %-18s v %-18s";
	$self->{recent_draws_format2} = " Home : %2d Away : %2d : %s";
}

=pod

=head1 NAME

View.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
