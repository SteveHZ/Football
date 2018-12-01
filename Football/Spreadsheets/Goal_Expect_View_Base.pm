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
		for my $team ( @{ $league->team_list } ) {
			printf "\n%-25s", $team;
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
	$self->do_goal_expect_header ($worksheet);

	my $formats = $self->get_all_formats ();
#	$self->blank_columns ( [ qw( 2 4 6 9 11 14 16 19 22 25 27 28 29 31 ) ] );
	my $row = 2;
	for my $game (@$fixtures) {
		my $expect_data = $self->get_expect_data ($game);
		my $row_data = $self->do_formats ($expect_data, $formats, $game);
		$self->write_row ($worksheet, $row, $row_data);
		$row ++;
	}
}

sub do_formats {
	my ($self, $data, $formats, $game) = @_;
	my $idx = 0;
	my @row_data = map { { $_ => @$formats [$idx++] } } @$data;

#   get formats for Home Team, Away Team, Home/Away and Last Six
	$row_data [2] = { @$data [2] => $self->get_format ( $game->{expected_goal_diff} * -1 ) };
	$row_data [3] = { @$data [3] => $self->get_format ( $game->{expected_goal_diff} ) };
	$row_data [6] = { @$data [6] => $self->get_format ( $game->{expected_goal_diff} ) };
	$row_data [9] = { @$data [9] => $self->get_format ( $game->{expected_goal_diff_last_six} ) };
	return \@row_data;
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format} : $self->{bold_float_format};
}

sub write_data {
	my ($self, $leagues, $teams, $fixtures) = @_;

	for my $league (@$leagues) {
		my $league_name = $league->name;

		my $worksheet = $self->add_worksheet ($league_name);
		do_write_data_header ($worksheet, $self->{bold_format});

		$self->blank_columns ( [ qw(1 4 7 10 13 16 19 22) ] );
		my $row = 2;
		for my $team ( @{ $league->team_list } ) {
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

		{ $teams->{$team}->{last_six_for} => $self->{format} },
		{ $teams->{$team}->{av_last_six_for} => $self->{float_format} },
		{ $teams->{$team}->{last_six_against} => $self->{format} },
		{ $teams->{$team}->{av_last_six_against} => $self->{float_format} },
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
	$worksheet->merge_range ('U1:V1', "Last Six For", $format);
	$worksheet->merge_range ('X1:Y1', "Last Six Ag", $format);
}

sub get_expect_data {
	my ($self, $game) = @_;
	state $rules = $self->get_rules ();

	return [
		$game->{league}, $game->{date}, $game->{home_team}, $game->{away_team},
		$game->{home_goals}, $game->{away_goals}, $game->{expected_goal_diff},
		$game->{home_last_six}, $game->{away_last_six}, $game->{expected_goal_diff_last_six},

		$rules->points_rule ( $game->{home_points}, $game->{away_points} ),
		$rules->points_rule ( $game->{last_six_home_points}, $game->{last_six_away_points} ),
		$rules->goal_diffs_rule ( $game->{rgd_results} ),
		$rules->goal_diffs_rule ( $game->{gd_results} ),

		$rules->home_away_rule ( $game ),
		$rules->last_six_rule ( $game ),

		$rules->match_odds_rule ( $game ),
		$rules->ou_points_rule ($game),
		$rules->ou_home_away_rule ( $game ),
		$rules->ou_last_six_rule ( $game ),
		$rules->over_odds_rule ( $game ),
		$rules->under_odds_rule ( $game ),
	];
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
		undef,
#	last_six
		$self->{float_format},
		$self->{float_format},
		undef,
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

=head
sub get_goal_expect_rows {
	my ($self, $game) = @_;
	state $rules = $self->get_rules ();

	return [
		{ $game->{league} => $self->{format} },
		{ $game->{date} => $self->{blank_text_format2} },
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
		{ $rules->ou_points_rule ($game) => $self->{blank_text_format} },
		{ $rules->ou_home_away_rule ( $game ) => $self->{percent_format} },
		{ $rules->ou_last_six_rule ( $game ) => $self->{percent_format} },
		{ $rules->over_odds_rule ( $game ) => $self->{blank_text_format} },
		{ $rules->under_odds_rule ( $game ) => $self->{blank_text_format} },
	];
}
=cut

1;
