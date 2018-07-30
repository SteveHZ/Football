package Football::Spreadsheets::Over_Under_View;

#	Football::Spreadsheets::Over_Under_View.pm 26/07/17

use List::MoreUtils qw(each_arrayref);
use Football::Utils qw(_show_signed);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my $self = shift;

	$self->create_sheet ();
	$self->{sheet_names} = ["Home and Away", "Last Six", "Over Under", "OU Points"];
	$self->{sorted_by} = ["ou_home_away", "ou_last_six", "ou_odds", "ou_points"];
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'over_under.xlsx';
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
		do_over_under_header ($worksheet, $self->{format});

		my $row = 2;
		for my $game (@{ $fixtures->{$sorted_by} } ) {
			$self->blank_columns ( [ qw( 1 3 5 8 10 13 15) ] );
		
			my $row_data = ($sheet_name eq "OU Points") ?
				$self->get_over_under_points_rows ($game) : $self->get_over_under_rows ($game);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub get_over_under_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },

		{ $game->{home_over_under} => $self->{format} },
		{ $game->{away_over_under} => $self->{format} },
		{ $game->{home_away} => $self->{percent_format} },

		{ $game->{home_last_six_over_under} => $self->{format} },
		{ $game->{away_last_six_over_under} => $self->{format} },
		{ $game->{last_six} => $self->{percent_format} },
		
		{ $game->{over_2pt5} => $self->{float_format} },
		{ $game->{under_2pt5} => $self->{float_format} },
	];
}

sub get_over_under_points_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },

		{ $game->{points} => $self->{float_format} },
	];
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format} : $self->{bold_float_format};
} 

sub do_over_under_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ($_, 20) for ('A:A','C:C','E:E');
	$worksheet->set_column ($_, 10) for ('J:J','O:O','Q:R');
	$worksheet->set_column ($_, 6) for ('G:H','L:M');
	$worksheet->set_column ($_, 2.5) for ('B:B','D:D','F:F','I:I','K:K','N:N','P:P');
	
	$worksheet->write ('A1', "League", $format);
	$worksheet->write ('C1', "Home", $format);
	$worksheet->write ('E1', "Away", $format);
	$worksheet->merge_range ('G1:J1', "HOMES & AWAYS", $format);
	$worksheet->merge_range ('L1:O1', "LAST SIX", $format);
	$worksheet->merge_range ('Q1:R1', "O/U ODDS", $format);
	
	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

1;
