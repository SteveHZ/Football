package Football::GoalExpect_View;

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/';
my $football_filename = $path.'goal_expect.xlsx';
my $rugby_filename = $path.'Rugby/rugby_expect.xlsx';

sub BUILD {
	my ($self, $args) = @_;
	my $sport = $args->{sport};
	$sport //= "Football";

	$self->{filename} = ($sport eq "Football") ? $football_filename : $rugby_filename;
}

after 'BUILD' => sub {
	my $self = shift;
	
	$self->{blank_column_format} = $self->copy_format ( $self->{format} );
	$self->{blank_column_format}->set_num_format ('@');

	$self->{blank_column_format2} = $self->copy_format ( $self->{blank_column_format} );
	$self->{blank_column_format2}->set_color ('black');
	$self->{blank_column_format2}->set_bg_color ('white');

	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
	$self->{bold_float_format}->set_color ('orange');
	$self->{bold_float_format}->set_bold ();
};

sub view {
	my ($self, $leagues, $teams, $fixtures) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{title};
		print "\n\n$league_name :";
		for my $team ( @{ $league->{team_list} } ) {
			printf "\n%-20s", $team;
			print "$teams->{$team}->{home_for} - ";
			print "$teams->{$team}->{av_home_for} ";
			print "$teams->{$team}->{home_against} - ";
			print "$teams->{$team}->{av_home_against} ";

			print "$teams->{$team}->{away_for} - ";
			print "$teams->{$team}->{av_away_for} ";
			print "$teams->{$team}->{away_against} - ";
			print "$teams->{$team}->{av_away_against} ";

			print "$teams->{$team}->{expect_home_for} - ";
			print "$teams->{$team}->{expect_home_against} ";
			print "$teams->{$team}->{expect_away_for} - ";
			print "$teams->{$team}->{expect_away_against} ";
		}
	}
	$self->do_goal_expect ($fixtures); 
	$self->write_data ($leagues, $teams, $fixtures);
}

sub do_goal_expect {
	my ($self, $fixtures) = @_;
	my $worksheet = $self->add_worksheet ("Goal Expect");
	do_goal_expect_header ($worksheet, $self->{bold_format}, $self->{blank_column_format}, $self->{blank_column_format2});

	my $row = 2;
	for my $game (@$fixtures) {
		my $blank_cols = [ qw(1 3 5 8 10 13 15 18) ];
		
		my $row_data = $self->get_goal_expect_rows ($game);
		$self->write_row ($worksheet, $row, $row_data, $blank_cols);
		$row ++;
	}
}

sub write_data {
	my ($self, $leagues, $teams, $fixtures) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{title};

		my $worksheet = $self->add_worksheet ($league_name);
		do_write_data_header ($worksheet, $self->{bold_format});
		my $row = 2;
		for my $team ( @{ $league->{team_list} } ) {
			my $blank_cols = [ qw(1 4 7 10 13 16) ];

			my $row_data = $self->get_write_data_rows ($teams, $team);
			$self->write_row ($worksheet, $row, $row_data, $blank_cols);
			$row ++;
		}
		$worksheet->write ( ++$row, 0, "Average Home Goals", $self->{format} );
		$worksheet->write ( $row, 2, $league->{av_home_goals}, $self->{float_format} );
		$worksheet->write ( ++$row, 0, "Average Away Goals", $self->{format} );
		$worksheet->write ( $row, 2, $league->{av_away_goals}, $self->{float_format} );
	}
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format} : $self->{bold_float_format};
} 

sub get_goal_expect_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff} ) },
		{ $game->{home_goals} => $self->{float_format} },
		{ $game->{away_goals} => $self->{float_format} },
		{ $game->{expected_goal_diff} => $self->get_format ( $game->{expected_goal_diff} ) },

		{ $game->{home_goals2} => $self->{float_format} },
		{ $game->{away_goals2} => $self->{float_format} },
		{ $game->{expected_goal_diff2} => $self->get_format ( $game->{expected_goal_diff2} ) },
	];
}

sub get_write_data_rows {
	my ($self, $teams, $team) = @_;
	return [
		{ $team => $self->{format} },
		{ $teams->{$team}->{home_for} => $self->{format} },
		{ $teams->{$team}->{av_home_for} => $self->{float_format} },
		{ $teams->{$team}->{home_against} => $self->{format} },
		{ $teams->{$team}->{av_home_against} => $self->{float_format} },
		{ $teams->{$team}->{away_for} => $self->{format} },
		{ $teams->{$team}->{av_away_for} => $self->{float_format} },
		{ $teams->{$team}->{away_against} => $self->{format} },
		{ $teams->{$team}->{av_away_against} => $self->{float_format} },
		{ $teams->{$team}->{expect_home_for} => $self->{float_format} },
		{ $teams->{$team}->{expect_home_against} => $self->{float_format} },
		{ $teams->{$team}->{expect_away_for} => $self->{float_format} },
		{ $teams->{$team}->{expect_away_against} => $self->{float_format} },
	];
}

sub do_goal_expect_header {
	my ($worksheet, $format, $blank_column_format, $blank_column_format2) = @_;

	$worksheet->set_column ($_, 20) for ('A:A','C:C','E:E');
	$worksheet->set_column ($_, 4) for ('K:K','P:P');
#	$worksheet->set_column ($_, 6) for ('G:H','J:J','L:M','O:O');
#	$worksheet->set_column ($_, 2.5) for ('B:B','D:D','F:F','I:I','N:N');
	$worksheet->set_column ($_, 6) for ('G:H','J:J');
	$worksheet->set_column ($_, 2.5) for ('B:B','D:D','F:F','I:I','X:X');
	$worksheet->set_column ('L:P', undef, undef, 1); # hide columns
	
	$worksheet->set_column ($_, 6, $blank_column_format) for ('Q:Q','S:S','U:U','W:W');
	$worksheet->set_column ($_, 6, $blank_column_format2) for ('R:R','T:T','V:V');

	$worksheet->write ('A1', "League", $format);
	$worksheet->write ('C1', "Home", $format);
	$worksheet->write ('E1', "Away", $format);
	$worksheet->write ('G1', "H", $format);
	$worksheet->write ('H1', "A", $format);
	$worksheet->write ('J1', "GD", $format);
	
	$worksheet->write ('Q1', "H/A", $format);
	$worksheet->write ('R1', "LSG", $format);
	$worksheet->write ('S1', "RGD", $format);
	$worksheet->write ('T1', "GD", $format);
	$worksheet->write ('U1', "LP", $format);
	$worksheet->write ('W1', "ODDS", $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_write_data_header {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ('A:A', 20);
	$worksheet->set_column ('B:S' , 6);

	$worksheet->write ('A1', "Team", $format);
	$worksheet->merge_range ('C1:D1', "Home For", $format);

	$worksheet->merge_range ('F1:G1', "Home Against", $format);
	$worksheet->merge_range ('I1:J1', "Away For", $format);
	$worksheet->merge_range ('L1:M1', "Away Against", $format);
	$worksheet->merge_range ('O1:P1', "Home F/A", $format);
	$worksheet->merge_range ('R1:S1', "Away F/A", $format);
}

1;
