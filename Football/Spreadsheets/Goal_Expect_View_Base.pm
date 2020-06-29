package Football::Spreadsheets::Goal_Expect_View_Base;

use v5.10; # state
use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ();
}

# must be implemented by child classes
sub create_sheet {}

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
	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );

	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
	$self->{bold_float_format}->set_color ('orange');
	$self->{bold_float_format}->set_bold ();

	$self->{float_format2} = $self->copy_format ( $self->{float_format} );
	$self->{float_format2}->set_num_format ('#,##0.0#'); # for combined.pl
};

sub view {
	my ($self, $leagues, $teams, $fixtures) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->name;
		print "\n\n$league_name :";
		for my $team ( $league->team_list->@* ) {
			printf "\n%-25s", $team;
			printf "%2d - %.2f ", $teams->{$team}->{home_for},
				                  $teams->{$team}->{av_home_for};
			printf "%2d - %.2f ", $teams->{$team}->{home_against},
				                  $teams->{$team}->{av_home_against};

			printf "%2d - %.2f ", $teams->{$team}->{away_for},
			                      $teams->{$team}->{av_away_for};
			printf "%2d - %.2f ", $teams->{$team}->{away_against},
				                  $teams->{$team}->{av_away_against};

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
	$self->blank_columns ( [ qw( 2 4 6 9 11 14 16 19 22 25 27 28 29 31 ) ] );
	$self->do_goal_expect_header ($worksheet);

	my $row = 2;
	for my $game (@$fixtures) {
		my $row_data = $self->do_formats ($game);
		$self->write_row ($worksheet, $row, $row_data);
		$row ++;
	}
}

sub do_formats {
	my ($self, $game) = @_;
	my $idx = 0;
	state $formats = $self->get_all_formats ();
	my @row_data = map { { $_ => @$formats [$idx++] } } @$game;

#   get formats for Home Team, Away Team, Home/Away and Last Six
	$row_data [2] = { @$game [2] => $self->get_format ( @$game [6] * -1 ) };	# expected_goal_diff
	$row_data [3] = { @$game [3] => $self->get_format ( @$game [6] ) }; 		# expected_goal_diff
	$row_data [6] = { @$game [6] => $self->get_format ( @$game [6] ) }; 		# expected_goal_diff
	$row_data [9] = { @$game [9] => $self->get_format ( @$game [9] ) }; 		# expected_goal_diff_last_six

	return \@row_data;
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format}
	                         : $self->{bold_float_format};
}

sub write_data {
	my ($self, $leagues, $teams, $fixtures) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->name;

		my $worksheet = $self->add_worksheet ($league_name);
		do_write_data_header ($worksheet, $self->{bold_format});

		$self->blank_columns ( [ qw(1 4 7 10 13 16 19 22) ] );
		my $row = 2;
		for my $team ( $league->team_list->@* ) {
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

		{ $teams->{$team}->{expect_last_six_home_for} => $self->{float_format} },
		{ $teams->{$team}->{expect_last_six_home_against} => $self->{float_format} },
		{ $teams->{$team}->{expect_last_six_away_for} => $self->{float_format} },
		{ $teams->{$team}->{expect_last_six_away_against} => $self->{float_format} },
	];
}

sub do_goal_expect_header {
	my ($self, $worksheet) = @_;

	$self->set_columns ($worksheet, $self->get_expect_columns ());
	$worksheet->set_column ($_, undef, undef, 1) for (qw (B:B G:I L:N)); # hide columns

	$worksheet->write ('A1', "League", $self->{format} );
	$worksheet->write ('D1', "Home", $self->{format} );
	$worksheet->write ('F1', "Away", $self->{format} );
	$worksheet->write ('H1', "H", $self->{format} );
	$worksheet->write ('I1', "A", $self->{format} );

	$worksheet->write ('K1', "H/A", $self->{format} );
	$worksheet->write ('P1', "L6", $self->{format} );

	$worksheet->write ('R1', "H/A", $self->{format} );
	$worksheet->write ('S1', "LSG", $self->{format} );
	$worksheet->write ('U1', "RGD", $self->{format} );
	$worksheet->write ('V1', "GD", $self->{format} );

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (2,0);
}

sub get_expect_columns {
	my $self = shift;

	return {
		"A B D F" => 20,
		"C E G J L O Q T" => 2.5,
		"H I K L M P" => 6,

		"R:S U:V" => { size => 6, fmt => $self->{float_format} },
		W => { size => 2.5, fmt => $self->{blank_number_format2} },
	};
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
	$worksheet->merge_range ('U1:V1', "L6 Home F/A", $format);
	$worksheet->merge_range ('X1:Y1', "L6 Ag F/A", $format);
}

sub get_all_formats {
	my $self = shift;
	$self->blank_columns ( [ qw( 2 4 6 9 11 14 16 19 22 25 27 28 29 31 ) ] );
	return [
		$self->{format},
		$self->{blank_text_format2},
		undef,
		undef,
#	home_away
		$self->{float_format},
		$self->{float_format},
		undef,	# calculate later in do_formats
#	last_six
		$self->{float_format},
		$self->{float_format},
		undef, # calculate later in do_formats
#	h/a lastsix
		$self->{blank_text_format},
		$self->{blank_text_format},
#	rgd/gd
		$self->{blank_text_format},
		$self->{blank_text_format},
#	goal diff
		$self->{blank_text_format},
		$self->{blank_text_format},
#	match_odds_rule
		$self->{format},
		$self->{float_format},
		$self->{percent_format},
		$self->{percent_format},
		$self->{percent_format},
		$self->{percent_format},
		$self->{blank_text_format},
		$self->{blank_text_format},
	];
}

1;
