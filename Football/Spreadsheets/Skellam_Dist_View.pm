package Football::Spreadsheets::Skellam_Dist_View;

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ();
	$self->{show_max} = 5;
	$self->{show_min} = $self->{show_max} * -1;
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'skellam.xlsx';
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

	$self->{blank_number_format3} = $self->copy_format ($self->{blank_text_format2} );
	$self->{blank_number_format3}->set_num_format ('#0');

	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
	$self->{bold_float_format}->set_color ('orange');
	$self->{bold_float_format}->set_bold ();
};

sub view {
	my ($self, $fixtures) = @_;

	for my $game (@$fixtures) {
		print "\n$game->{home_team} v $game->{away_team}";
		print " [ $game->{home_goals} - $game->{away_goals} ]";
	}
	$self->do_skellam ($fixtures);
}

sub do_skellam {
	my ($self, $fixtures) = @_;
	my $worksheet = $self->add_worksheet ('Skellam Distribution');
	$self->do_skellam_header ($worksheet);

	$self->blank_columns ( [ qw( 1 4 8 14 16 ) ] );
	my $row = 2;
	for my $game (@$fixtures) {
		my $row_data = $self->get_skellam_rows ($game);
		$self->write_row ($worksheet, $row, $row_data);
		$row ++;
	}
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format} : $self->{bold_float_format};
}

sub get_skellam_rows {
	my ($self, $game) = @_;

	my @rows = (
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff} ) },
	);
	push (@rows,
		{ $game->{skellam}->{home_win} => $self->{percent_format} },
		{ $game->{skellam}->{draw} => $self->{percent_format} },
		{ $game->{skellam}->{away_win} => $self->{percent_format} },
	);
	if ( defined $game->{skellam}->{0} ) {
		for my $count ( reverse $self->{show_min}..$self->{show_max} ) {
			push (@rows,
				{ $game->{skellam}->{$count} => $self->{float_format} }
			);
		}
	}
	return \@rows;
}

sub do_skellam_header {
	my ($self, $worksheet) = @_;

	$worksheet->set_column ($_, 20) for (qw (A:A C:D));
	$worksheet->set_column ($_, 8) for (qw (F:H));
	$worksheet->set_column ($_, 6) for (qw (J:N P:P R:V));
	$worksheet->set_column ($_, 2.5) for (qw (B:B E:E I:I O:O Q:Q));

	$worksheet->write ('A1', 'League', $self->{format} );
	$worksheet->write ('C1', 'Home', $self->{format} );
	$worksheet->write ('D1', 'Away', $self->{format} );
	$worksheet->write ('F1', 'HW', $self->{format} );
	$worksheet->write ('H1', "AW', $self->{format} );
	$worksheet->write ('G1', 'Draw', $self->{format} );

	$worksheet->write ('J1', '+5', $self->{format} );
	$worksheet->write ('K1', '+4', $self->{format} );
	$worksheet->write ('L1', '+3', $self->{format} );
	$worksheet->write ('M1', '+2', $self->{format} );
	$worksheet->write ('N1', '+1', $self->{format} );
	$worksheet->write ('P1', '0', $self->{format} );

	$worksheet->write ('R1', '-1', $self->{format} );
	$worksheet->write ('S1', '-2', $self->{format} );
	$worksheet->write ('T1', '-3', $self->{format} );
	$worksheet->write ('U1', '-4', $self->{format} );
	$worksheet->write ('V1', '-5', $self->{format} );

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (2,0);
}

1;
