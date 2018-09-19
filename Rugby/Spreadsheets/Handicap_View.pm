package Rugby::Spreadsheets::Handicap_View;

#	Rugby::Spreadsheets::Handicap_View.pm 09/04/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/Rugby/handicaps';

sub BUILD {
	my ($self, $args) = @_;
	$self->{league} = $args->{league};
	$self->{filename} = $path."/".$args->{league}.".xlsx";
}

sub write {
	my ($self, $team_list, $handicaps) = @_;

	print "\nWriting handicap data for $self->{league}...";
	for my $team (@$team_list) {
		my $teamref = $handicaps->fetch_hash ( $self->{league}, $team );
		my $worksheet = $self->add_worksheet ($team);
		$self->do_header ($worksheet);

		my $row = 2;
		$self->blank_columns ( [ qw ( 1 3 5 6 8 10 ) ] );
		for (my $margin = 50; $margin > 0; $margin -= 2) {
			my $row_data = $self->get_row_data ($teamref, $margin);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
		$self->do_footer ($worksheet, $teamref, ++$row)
	}
	$self->{workbook}->close ();
}

sub get_row_data {
	my ($self, $teamref, $margin) = @_;

	my $loss_margin = $margin * -1;
	my $percent = $teamref->{$margin} / $teamref->{games};
	my $loss_percent = $teamref->{$loss_margin} / $teamref->{games};

	return [
		{ $margin, $self->{format} },
		{ $teamref->{$margin}, $self->{format} },
		{ $percent, $self->{percent_format} },

		{ $loss_margin, $self->{format} },
		{ $teamref->{$loss_margin}, $self->{format} },
		{ $loss_percent, $self->{percent_format} },
	];
}

sub do_header {
	my ($self, $worksheet) = @_;

	$worksheet->set_column ($_, 14) for (qw (A:A H:H));
	$worksheet->set_column ($_, 10) for (qw (C:C J:J));
	$worksheet->set_column ($_, 4) for (qw (B:B D:D K:K M:M));
	$worksheet->set_column ($_, 20) for (qw (E:E L:L));

	$worksheet->write ('A1', 'Win Margin', $self->{bold_format});
	$worksheet->write ('H1', 'Loss Margin', $self->{bold_format});
	$worksheet->write ($_, 'Games', $self->{bold_format}) for (qw (C1 J1));
	$worksheet->write ($_, 'Percentage', $self->{bold_format}) for (qw (E1 L1));
}

sub do_footer {
	my ($self, $worksheet, $teamref, $row) = @_;

	$worksheet->merge_range ($row, 0, $row, 1, 'Games played', $self->{format});
	$worksheet->write ($row, 2, $teamref->{games}, $self->{bold_format});
	$worksheet->write ($row, 4, 'Won', $self->{format});
	$worksheet->write ($row, 5, $teamref->{won}, $self->{bold_format});
	$worksheet->write ($row, 7, 'Lost', $self->{format});
	$worksheet->write ($row, 8, $teamref->{lost}, $self->{bold_format});
}

1;
