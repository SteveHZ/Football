package Football::Spreadsheets::Goal_Expect_View_Base_v3;

use lib 'C:/Mine/perl/Football';
#use Football::Rules;
use v5.10; # state

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ();
}0

# must be implemented by child classes
sub create_sheet {}
sub get_rules {}

after 'BUILD' => sub {
	my $self = shift;
	
	$self->{blank_text_format} = $self->copy_format ( $self->{format} );
	$self->{blank_text_format}->set_num_format ('@');

	$self->{blank_number_format} = $self->copy_format ( $self-> {blank_text_format} );
	$self->{blank_number_format}->set_num_format ('#0.00');

	$self->{blank_text_format2} = $self->copy_format ( $self->{blank_text_format} );
	$self->{blank_text_format2}->set_color ('black');
	$self->{blank_text_format2}->set_bg_color ('white');

	$self->{blank_number_format2} = $self->copy_format ($self->{blank_text_format2} );
	$self->{blank_number_format2}->set_num_format ('#0.00');
	
	$self->{blank_number_format3} = $self->copy_format ($self->{blank_text_format2} );
	$self->{blank_number_format3}->set_num_format ('#0');

	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
	$self->{bold_float_format}->set_color ('orange');
	$self->{bold_float_format}->set_bold ();
};

sub view {
	my ($self, $leagues, $teams, $fixtures) = @_;

#	for my $league (@$leagues) {
#		my $league_name = $league->{title};
#		print "\nWriting $league_name :";
#		for my $team ( @{ $league->{team_list} } ) {
#			printf "\n%-25s", $team;
#			print "$teams->{$team}->{home_for} - ";
#			print "$teams->{$team}->{av_home_for} ";
#			print "$teams->{$team}->{home_against} - ";
#			print "$teams->{$team}->{av_home_against} ";
#
#			print "$teams->{$team}->{away_for} - ";
#			print "$teams->{$team}->{av_away_for} ";
#			print "$teams->{$team}->{away_against} - ";
#			print "$teams->{$team}->{av_away_against} ";
#
#			print "$teams->{$team}->{expect_home_for} - ";
#			print "$teams->{$team}->{expect_home_against} ";
#			print "$teams->{$team}->{expect_away_for} - ";
#			print "$teams->{$team}->{expect_away_against} ";
#		}
#	}
	$self->do_goal_expect ($fixtures); 
	$self->write_data ($leagues, $teams, $fixtures);
}

sub do_goal_expect {
	my ($self, $fixtures) = @_;
	
	my $worksheet = $self->add_worksheet ("Goal Expect");
	$self->do_goal_expect_header ($worksheet);

	$self->blank_columns ( [ qw( 1 3 5 8 10 13 15 18 21 24 25 26 27 28 ) ] );
	my $row = 2;
	for my $game (@$fixtures) {
		my $row_data = $self->get_goal_expect_rows ($game);
		$self->write_row ($worksheet, $row, $row_data);
		$row ++;
	}
}

sub write_data {
	my ($self, $leagues, $teams, $fixtures) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->{title};

		my $worksheet = $self->add_worksheet ($league_name);
		do_write_data_header ($worksheet, $self->{bold_format});

		$self->blank_columns ( [ qw(1 4 7 10 13 16 19 22) ] );
		my $row = 2;
		for my $team ( @{ $league->{team_list} } ) {
			my $row_data = $self->get_write_data_rows ($teams, $team);
			$self->write_row ($worksheet, $row, $row_data);
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
	state $rules = $self->get_rules ();
#	state $rules = Football::Rules->new ();
	
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff} ) },
		{ $game->{home_goals} => $self->{float_format} },
		{ $game->{away_goals} => $self->{float_format} },
		{ $game->{expected_goal_diff} => $self->get_format ( $game->{expected_goal_diff} ) },

		{ $game->{home_last_six} => $self->{float_format} },
		{ $game->{away_last_six} => $self->{float_format} },
		{ $game->{expected_goal_diff_last_six} => $self->get_format ( $game->{expected_goal_diff_last_six} ) },

		{ $rules->points_rule ( $game->{home_points}, $game->{away_points} ) => $self->{blank_text_format} },
		{ $rules->points_rule ( $game->{last_six_home_points}, $game->{last_six_away_points} ) => $self->{blank_text_format} },

		{ $rules->goal_diffs_rule ( $game->{rgd_results} ) => $self->{blank_text_format} },
		{ $rules->goal_diffs_rule ( $game->{gd_results} ) => $self->{blank_text_format} },

		{ $rules->home_away_rule ( $game ) => $self->{blank_text_format} },
		{ $rules->last_six_rule ( $game ) => $self->{blank_text_format} },

		{ $rules->match_odds_rule ( $game ) => $self->{blank_text_format} },
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

		{ $teams->{$team}->{last_six_for} => $self->{format} },
		{ $teams->{$team}->{av_last_six_for} => $self->{float_format} },
		{ $teams->{$team}->{last_six_against} => $self->{format} },
		{ $teams->{$team}->{av_last_six_against} => $self->{float_format} },
	];
}

sub do_goal_expect_header {
	my ($self, $worksheet) = @_;

	$worksheet->set_column ($_, 20) for ('A:A','C:C','E:E');
	$worksheet->set_column ($_, 6) for ('G:H','J:J','L:M','O:O');
	$worksheet->set_column ($_, 2.5) for ('B:B','D:D','F:F','I:I','K:K','N:N','P:P','S:S');
	$worksheet->set_column ('L:P', undef, undef, 1); # hide columns
	
	$worksheet->set_column ($_, 6, $self->{blank_text_format} ) for ('Q:R','T:U');
	$worksheet->set_column ($_, 2.5, $self->{blank_number_format2} ) for ('V:V');

	$worksheet->write ('A1', "League", $self->{format} );
	$worksheet->write ('C1', "Home", $self->{format} );
	$worksheet->write ('E1', "Away", $self->{format} );
	$worksheet->write ('G1', "H", $self->{format} );
	$worksheet->write ('H1', "A", $self->{format} );

	$worksheet->write ('J1', "H/A", $self->{format} );
	$worksheet->write ('O1', "L6", $self->{format} );
	
	$worksheet->write ('Q1', "H/A", $self->{format} );
	$worksheet->write ('R1', "LSG", $self->{format} );
	$worksheet->write ('T1', "RGD", $self->{format} );
	$worksheet->write ('U1', "GD", $self->{format} );

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (2,0);
}

sub do_write_data_header {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ('A:A', 20);
	$worksheet->set_column ('B:Y' , 5.5);

	$worksheet->write ('A1', "Team", $format);
	$worksheet->merge_range ('C1:D1', "Home For", $format);
	$worksheet->merge_range ('F1:G1', "Home Ag", $format);
	$worksheet->merge_range ('I1:J1', "Away For", $format);
	$worksheet->merge_range ('L1:M1', "Away Ag", $format);
	$worksheet->merge_range ('O1:P1', "Home F/A", $format);
	$worksheet->merge_range ('R1:S1', "Away F/A", $format);
	$worksheet->merge_range ('U1:V1', "Last Six For", $format);
	$worksheet->merge_range ('X1:Y1', "Last Six Ag", $format);
}

1;
