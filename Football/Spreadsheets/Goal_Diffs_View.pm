package Football::Spreadsheets::Goal_Diffs_View;

use List::MoreUtils qw(each_arrayref);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet',
'Football::Roles::Signed'; # _show_signed

sub BUILD {
	my ($self, $args) = @_;

	$self->create_sheet ();
	$self->{sheet_names} = ['Goal Diffs', 'Home and Away', 'Last Six'];
	$self->{sorted_by} = ['grepped', 'home_away', 'last_six'];
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'goal_diffs.xlsx';
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
	my $iterator = each_arrayref ($self->{sheet_names}, $self->{sorted_by});

	while (my ($sheet_name, $sorted_by) = $iterator->() ) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		$worksheet->add_write_handler( qr/^-?\d+(?:\.\d+)?$/, \&signed_goal_diff);
		do_goal_diffs_header ($worksheet, $self->{format});

		my $row = 2;
		for my $game ( $fixtures->{$sorted_by}->@* ) {
			$self->blank_columns ( [ qw( 1 3 5 8 10 13 ) ] );

			my $row_data = $self->get_goal_diffs_rows ($game);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub get_goal_diffs_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff} ) },
		{ $game->{home_goal_diff} => $self->{float_format} },
		{ $game->{away_goal_diff} => $self->{float_format} },
		{ $game->{home_away_goal_diff} => $self->get_format ( $game->{home_away_goal_diff} ) },

		{ $game->{home_last_six_goal_diff} => $self->{float_format} },
		{ $game->{away_last_six_goal_diff} => $self->{float_format} },
		{ $game->{last_six_goal_diff} => $self->get_format ( $game->{last_six_goal_diff} ) },
	];
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format} : $self->{bold_float_format};
}

sub do_goal_diffs_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ($_, 25) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 10) for (qw (G:H J:J L:M O:O));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F I:I K:K N:N));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);
	$worksheet->merge_range ('G1:J1', 'HOMES & AWAYS', $format);
	$worksheet->merge_range ('L1:O1', 'LAST SIX', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub signed_goal_diff {
	return _show_signed (@_, [ qw(6 7 9 11 12 14) ] );
}

1;
