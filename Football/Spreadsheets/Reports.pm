package Football::Spreadsheets::Reports;

#	Spreadsheets::Reports.pm 01/03/16 - 13/04/16
#	v1.1 08/05/17, 29/06/17

use List::MoreUtils qw (each_arrayref);
use Football::Utils qw(_show_signed);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ($args->{report});
	$self->{size} = $args->{size} if exists $args->{size};
}

sub create_sheet {
	my ($self, $report) = @_;
	my $path = $self->get_path ();
	my $xlsx_files = {
		'League Places' 		 => $path.'league_places.xlsx',
		'Goal Difference'		 => $path.'goal_difference.xlsx',
		'Recent Goal Difference' => $path.'recent_goal_difference.xlsx',
		'Homes Aways Draws' 	 => $path.'homes_aways_draws.xlsx',
	};
	$self->{filename} = $xlsx_files->{$report};
}

sub get_path {
	return 'C:/Mine/perl/Football/reports/';
}

sub do_league_places {
	my ($self, $hash, $leagues, $league_size) = @_;

	print "\n\nWriting league_places report...";
	my $iterator = each_arrayref ($leagues, $league_size);
	while ( my ($league, $size) = $iterator->() ) {
		my $worksheet = $self->{workbook}->add_worksheet ($league);
		do_league_places_header ($worksheet, $self->{bold_format});

		my $row = 3;
		for my $home (1..$size) {
			for my $away (1..$size) {
				next if ($home == $away);
				$worksheet->write ($row, 0, $home, $self->{format});
				$worksheet->write ($row, 1, $away, $self->{format});
				$worksheet->write ($row, 3, $hash->{$league}->{$home}->{$away}->{home_win}, $self->{format});
				$worksheet->write ($row, 4, $hash->{$league}->{$home}->{$away}->{away_win}, $self->{format});
				$worksheet->write ($row, 5, $hash->{$league}->{$home}->{$away}->{draw}, $self->{format});
				$row++;
			}
		}
		$worksheet->freeze_panes (3,0);
	}
	$self->{workbook}->close ();
}

sub do_goal_difference {
	my ($self, $hash, $leagues) = @_;

	print "\n\nWriting goal_difference report...";
	for my $league (@$leagues) {
		my $worksheet = $self->{workbook}->add_worksheet ($league);
		$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);
		do_goal_diff_header ($worksheet, $self->{bold_format});

		my $row = 3;
		for my $goal_diff (-1 * $self->{size}..$self->{size}) {
			$worksheet->write ($row, 0, $goal_diff, $self->{format});
			$worksheet->write ($row, 2, $hash->{$league}->{$goal_diff}->{home_win}, $self->{format});
			$worksheet->write ($row, 3, $hash->{$league}->{$goal_diff}->{away_win}, $self->{format});
			$worksheet->write ($row, 4, $hash->{$league}->{$goal_diff}->{draw}, $self->{format});

			my $formulae = build_formulae ($row + 1); # 0,0 = A1
			my $per_cent_col = 7;
			for my $formula (@$formulae) {
				$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
			}
			$row++;
		}
		$worksheet->freeze_panes (3,0);
	}
	$self->{workbook}->close ();
}

sub do_recent_goal_diff {
	my ($self, $hash, $leagues) = @_;

	print "\n\nWriting recent_goal_difference report...";
	for my $league (@$leagues) {
		my $worksheet = $self->{workbook}->add_worksheet ($league);
		$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);
		do_goal_diff_header ($worksheet, $self->{bold_format});

		my $row = 3;
		for my $goal_diff (-1 * $self->{size}..$self->{size}) {
			$worksheet->write ($row, 0, $goal_diff, $self->{format});
			$worksheet->write ($row, 2, $hash->{$league}->{$goal_diff}->{home_win}, $self->{format});
			$worksheet->write ($row, 3, $hash->{$league}->{$goal_diff}->{away_win}, $self->{format});
			$worksheet->write ($row, 4, $hash->{$league}->{$goal_diff}->{draw}, $self->{format});

			my $formulae = build_formulae ($row + 1); # 0,0 = A1
			my $per_cent_col = 7;
			for my $formula (@$formulae) {
				$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
			}
			$row++;
		}
		$worksheet->freeze_panes (3,0);
	}
	$self->{workbook}->close ();
}

sub do_homeawaydraws {
	my ($self, $hash, $leagues) = @_;

	print "\n\nWriting home_away_draw report...";
	for my $league (@$leagues) {
		my $worksheet = $self->{workbook}->add_worksheet ($league);
		do_homeawaydraws_header ($worksheet, $self->{bold_format});

		my $row = 3;
		my @seasons = sort {$a <=> $b} keys %{ $hash->{$league} };
		for my $season (@seasons) {
			$worksheet->write ($row, 0, $season, $self->{format});
			$worksheet->write ($row, 2, $hash->{$league}->{$season}->{home_win}, $self->{format});
			$worksheet->write ($row, 3, $hash->{$league}->{$season}->{away_win}, $self->{format});
			$worksheet->write ($row, 4, $hash->{$league}->{$season}->{draw}, $self->{format});

			my $formulae = build_formulae ($row + 1); # 0,0 = A1
			my $per_cent_col = 7;
			for my $formula (@$formulae) {
				$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
			}
			$row++;
		}
		do_homeawaydraws_footer ($worksheet, $self->{format}, $self->{bold_format});
		$worksheet->freeze_panes (3,0);
	}
	$self->{workbook}->close ();
}

sub build_formulae {
	my $row = shift;
	return [
		'=IF(SUM(C'.$row.':E'.$row.'),(C'.$row.'/SUM(C'.$row.':E'.$row.'))*100,"0")',
		'=IF(SUM(C'.$row.':E'.$row.'),(D'.$row.'/SUM(C'.$row.':E'.$row.'))*100,"0")',
		'=IF(SUM(C'.$row.':E'.$row.'),(E'.$row.'/SUM(C'.$row.':E'.$row.'))*100,"0")',
	];
}

sub signed_goal_diff {
	return _show_signed (@_, [ 0 ]);
}

sub do_league_places_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:B', 15);
	$worksheet->set_column ('D:E', 15);

	$worksheet->merge_range ('A1:B1', 'League Positions', $format);
	$worksheet->merge_range ('D1:F1', 'Results', $format);

	$worksheet->write ('A2', 'Home', $format);
	$worksheet->write ('B2', 'Away', $format);

	$worksheet->write ('D2', 'Home Wins', $format);
	$worksheet->write ('E2', 'Away Wins', $format);
	$worksheet->write ('F2', 'Draws', $format);
}

sub do_goal_diff_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:A', 15);
	$worksheet->set_column ('C:E', 15);
	$worksheet->write ('A1', 'Goal Difference', $format);
	$worksheet->merge_range ('C1:E1', 'Results', $format);
	$worksheet->merge_range ('H1:J1', 'Percentages', $format);

	$worksheet->write ('C2', 'Home Wins', $format);
	$worksheet->write ('D2', 'Away Wins', $format);
	$worksheet->write ('E2', 'Draws', $format);

	$worksheet->write ('H2', 'Home', $format);
	$worksheet->write ('I2', 'Away', $format);
	$worksheet->write ('J2', 'Draw', $format);
}

sub do_homeawaydraws_header {
	my ($worksheet, $format) = @_;

	$worksheet->write ('A2', 'Season', $format);
	$worksheet->write ('C2', 'Homes', $format);
	$worksheet->write ('D2', 'Aways', $format);
	$worksheet->write ('E2', 'Draws', $format);
	$worksheet->merge_range ('H2:J2', 'Percentages', $format);
}

sub do_homeawaydraws_footer {
	my ($worksheet, $format, $bold_format) = @_;

	$worksheet->write ('A26', 'Totals', $bold_format);
	$worksheet->write ('C26', '=SUM(C4:C23)', $format);
	$worksheet->write ('D26', '=SUM(D4:D23)', $format);
	$worksheet->write ('E26', '=SUM(E4:E23)', $format);
	$worksheet->write ('H26', '=(C26/SUM(C26:E26))*100', $bold_format);
	$worksheet->write ('I26', '=(D26/SUM(C26:E26))*100', $bold_format);
	$worksheet->write ('J26', '=(E26/SUM(C26:E26))*100', $bold_format);
}

1;
