package Football::Spreadsheets::Match_Odds_View;

use List::MoreUtils qw(each_arrayref);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ();
	$self->{sheet_names} = ['Home Win', 'Away Win', 'Draw', 'Over 2.5', 'Under 2.5', 'BSTS Yes', 'BSTS No'];
	$self->{sorted_by} = ['home_win', 'away_win', 'draw', 'over_2pt5', 'under_2pt5', 'both_sides_yes', 'both_sides_no'];
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'match_odds.xlsx';
}

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

	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
	$self->{bold_float_format}->set_color ('orange');
	$self->{bold_float_format}->set_bold ();
};

sub view {
	my ($self, $fixtures) = @_;
	for my $game ($fixtures->{home_win}->@*) {
		print "\n\n$game->{home_team} v $game->{away_team}";
		print "\nHome Win : ".$game->{odds}->{home_win};
		print ' Away Win : '. $game->{odds}->{away_win};
		print ' Draw : '. $game->{odds}->{draw};
		print ' Both Sides Yes : '. $game->{odds}->{both_sides_yes};
		print ' Both Sides No : '. $game->{odds}->{both_sides_no};
		print ' Over 2.5 : '. $game->{odds}->{over_2pt5};
		print ' Under 2.5 : '. $game->{odds}->{under_2pt5};
	}
	$self->do_match_odds ($fixtures);
}

sub do_match_odds {
	my ($self, $fixtures) = @_;

	my $iterator = each_arrayref ($self->{sheet_names}, $self->{sorted_by});
	while (my ($sheet_name, $sorted_by) = $iterator->() ) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		do_goal_diffs_header ($worksheet, $self->{format});

		my $row = 2;
		for my $game ($fixtures->{$sorted_by}->@*) {
			$self->blank_columns ( [ qw( 1 3 5 9 12 15 ) ] );

			my $row_data = $self->get_match_odds_rows ($game);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub get_match_odds_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff} ) },

		{ $game->{odds}->{home_win} => $self->{float_format} },
		{ $game->{odds}->{draw} => $self->{float_format} },
		{ $game->{odds}->{away_win} => $self->{float_format} },

		{ $game->{odds}->{over_2pt5} => $self->{float_format} },
		{ $game->{odds}->{under_2pt5} => $self->{float_format} },
		{ $game->{odds}->{both_sides_yes} => $self->{float_format} },
		{ $game->{odds}->{both_sides_no} => $self->{float_format} },
	];
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format} : $self->{bold_float_format};
}

sub do_goal_diffs_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ($_, 25) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 10) for (qw (G:I K:L N:O));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F J:J M:M));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);

	$worksheet->write ('G1', 'Home Win', $format);
	$worksheet->write ('H1', 'Draw', $format);
	$worksheet->write ('I1', 'Away Win', $format);

	$worksheet->write ('K1', 'Over 2.5', $format);
	$worksheet->write ('L1', 'Under 2.5', $format);
	$worksheet->write ('N1', 'BSTS Yes', $format);
	$worksheet->write ('O1', 'BSTS No', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

1;
