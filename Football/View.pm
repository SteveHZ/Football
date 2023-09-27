package Football::View;

#	Football::View.pm 03/02/16, Mouse version 04/05/16
#	Moo version 01/10/16
#	v1.1 05-06/05/17

use Football::Spreadsheets::Teams;
use Football::Spreadsheets::Tables;
use Football::Spreadsheets::Predictions;
use Football::Spreadsheets::Extended;

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
}

sub destroy_sheets {
	my $self = shift;

	$self->{xlsx_teams}->{$_}->{workbook}->close () for keys $self->{xlsx_teams}->%*;
	$self->{xlsx_tables}->{$_}->{workbook}->close () for keys $self->{xlsx_tables}->%*;
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

	print "\n\nWriting data...";
	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $teams  = $league->{teams};
		my $sorted = $league->{team_list};
		print "\nWriting data for $league_name...";

		$self->{xlsx_teams}->{$league_name} = $self->create_new_teams_sheet ($league_name);
		$self->{xlsx_teams}->{$league_name}->do_teams ($teams, $sorted);
		print "Done";
	}
}

sub do_table {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $table = $league->{table}->sorted;

		$self->{xlsx_tables}->{$league_name} = $self->create_new_tables_sheet ($league_name);
		$self->{xlsx_tables}->{$league_name}->do_table ($table)
	}
}

sub do_home_table {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $table = $league->{home_table}->sorted;
		$self->{xlsx_tables}->{$league_name}->do_home_table ($table);
	}
}

sub do_away_table {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $table = $league->{away_table}->sorted;
		$self->{xlsx_tables}->{$league_name}->do_away_table ($table);
	}
}

sub homes {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $list = $league->{homes};
		$self->{xlsx_tables}->{$league_name}->do_homes ($list, "Last Six Homes");
	}
}

sub aways {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $list = $league->{aways};
		$self->{xlsx_tables}->{$league_name}->do_aways ($list, "Last Six Aways");
	}
}

sub last_six {
	my ($self, $leagues) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{name};
		my $list = $league->{last_six};
		$self->{xlsx_tables}->{$league_name}->do_last_six ($list, "Last Six Games");
	}
}

sub full_homes {
#	my ($self, $leagues) = @_;
}

sub full_aways {
#	my ($self, $leagues) = @_;
}

sub fixture_list {
	my ($self, $fixtures) = @_;

	print "\n\nWriting fixtures...\n";
	for my $game (@$fixtures) {
		print "\n$game->{league_idx} $game->{league} $game->{home_team} v $game->{away_team}";
	}
	print "\n";
}

sub fixtures {
	my ($self, $fixtures) = @_;

	print "\n\nWriting home/away predictions...\n";
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		print "\n$league_name :";
		for my $game ( $league->{games}->@* ) {
			print "\n";
			print " $_"  for ( $game->{homes}->@* );
			printf $self->{fixtures_format}, $game->{home_team}, $game->{away_team};
			print " $_"  for ( $game->{aways}->@* );
			printf $self->{fixtures_format2}, $game->{home_points}, $game->{away_points};
			printf "  %2d-%d", $game->{last_six_home_points}, $game->{last_six_away_points};
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
		for my $game ( $league->{games}->@* ) {
			print "\n";
			printf $self->{league_places_format}, $game->{home_team}, $game->{away_team};
			print " $_"  for ( $game->{head2head}->@* );
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

		for my $game ( $league->{games}->@* ) {
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

		for my $game ( $league->{games}->@* ) {
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

		for my $game ( $league->{games}->@*) {
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
