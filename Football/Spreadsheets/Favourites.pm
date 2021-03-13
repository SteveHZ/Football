package Football::Spreadsheets::Favourites;

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;

	$self->create_sheet ($args->{filename});

	$self->{dispatch} = {
		'by_year'   => sub { my $self = shift; $self->by_year (@_) },
		'by_league' => sub { my $self = shift; $self->by_league (@_) },
		'current'   => sub { my $self = shift; $self->current (@_) },
	};
}

after 'BUILD' => sub {
	my $self = shift;

	$self->{highlight_percent_format} = $self->{workbook}->add_format (
		bg_color => 'yellow',
		color => 'black',
		align => 'center',
		bold => 'true',
		border => 3,
		num_format => '0.00 %',
	);
};

sub create_sheet {
	my ($self, $filename) = @_;

	my $path = 'C:/Mine/perl/Football/reports/favourites/';
	$self->{file} = $filename;	# used for dispatch
	$self->{filename} = $path.$self->{file}.'.xlsx';
}

# used by favourites.pm from create_reports.pl

sub show {
	my ($self, $hash, $leagues, $seasons) = @_;
	$self->{dispatch}->{ $self->{file} }->( $self, $hash, $leagues, $seasons );
}

sub by_year {
	my ($self, $hash, $leagues, $seasons) = @_;
	my ($hashref, $row);

	print "\n";
	for my $year (@$seasons) {
		my $worksheet = $self->add_worksheet ($year);
		do_header ($worksheet, $self->{bold_format});

		$row = 4;
		for my $league (@$leagues) {
			$hashref = $hash->{$league}->{$year};

			print "\nWriting favourites by year : $league $year ...";
			$worksheet->write ($row, 0, $league, $self->{format});
			$self->write_row ($worksheet, $hashref, $row);
			$row += 2;
		}
	}
}

sub by_league {
	my ($self, $hash, $leagues, $seasons) = @_;
	my ($hashref, $row);

	print "\n";
	for my $league (@$leagues) {
		my $worksheet = $self->add_worksheet ($league);
		do_header ($worksheet, $self->{bold_format});

		$row = 4;
		for my $year (@$seasons) {
			$hashref = $hash->{$league}->{$year};

			print "\nWriting favourites by league : $league $year ...";
			$worksheet->write ($row, 0, $year, $self->{format});
			$self->write_row ($worksheet, $hashref, $row);
			$row += 2;
		}
	}
}

#	only used by favourites.pl -c ???

sub current {
	my ($self, $hash, $leagues, $seasons) = @_;
	my ($hashref, $row);
	my $year = @$seasons [0];

	my $worksheet = $self->add_worksheet ($year);
	do_header ($worksheet, $self->{bold_format});

	$row = 4;
	for my $league (@$leagues) {
		$hashref = $hash->{$league}->{$year};

		print "\nWriting favourites : $league $year ...";
		$worksheet->write ($row, 0, $league, $self->{format});
		$self->write_row ($worksheet, $hashref, $row);
		$row += 2;
	}
}

# end used by favourites.pm from create_reports.pl

# used by predict.pl

sub do_favourites {
	my ($self, $hash) = @_;
	my $year = $hash->{year};
	my $worksheet = $self->add_worksheet ($year);

	do_header ($worksheet, $self->{bold_format});
	print "\n";
	my $row = 4;
	my $leagues = $hash->{leagues};

	for my $league (@$leagues) {
		my $hashref = $hash->{data}->{$league}->{$year};

		print "\nWriting favourites : $league $year ...\n";
		$worksheet->write ($row, 0, $league, $self->{format});
		$self->write_row ($worksheet, $hashref, $row);
		$row += 2;
	}
	$self->do_history ($hash); # uncomment once all leagues included
}

sub do_history {
	my ($self, $hash) = @_;
	my $leagues = $hash->{leagues};
	my $year = $hash->{year};
	my $league_sheets = {};

	for my $league (@$leagues) {
		$league_sheets->{$league} = $self->add_worksheet ($league);
		do_header ($league_sheets->{$league}, $self->{bold_format});
	}

	my $row = 4;
	for my $week ( $hash->{history}->@* ) {
		for my $league (keys %$week) {
			my $hashref = $week->{$league}->{$year};
			$self->write_row ($league_sheets->{$league}, $hashref, $row);
		}
		$row ++;
	}
}

# end used by predict.pl

# used by all

sub do_header {
	my ($worksheet, $format) = @_;
	my ($row, $col) = (2,1);

	$worksheet->set_column ('A:A', 20);
	$worksheet->set_column ($_, 12) for (qw (B:B D:E G:H J:K));
	$worksheet->set_column ($_, 3) for (qw (C:C F:F I:I));

	$worksheet->merge_range ('D2:E2', 'Underdogs', $format);
	$worksheet->merge_range ('G2:H2', 'Favourites', $format);
	$worksheet->merge_range ('J2:K2', 'Draws', $format);

	$worksheet->write ($row, $col, 'Stake', $format);
	$col +=2;
	$worksheet->write ($row, $col ++, 'Return', $format);
	$worksheet->write ($row, $col, 'Profit', $format);
	$col +=2;
	$worksheet->write ($row, $col ++, 'Return', $format);
	$worksheet->write ($row, $col, 'Profit', $format);
	$col +=2;
	$worksheet->write ($row, $col ++, 'Return', $format);
	$worksheet->write ($row, $col, 'Profit', $format);
}

sub write_row {
	my ($self, $worksheet, $hashref, $row) = @_;
	my $col = 1;
	my $percent;

	$worksheet->write ($row, $col, $hashref->{stake}, $self->{currency_format});

	$col += 2;
	$worksheet->write ($row, $col ++, $hashref->{under_winnings}, $self->{currency_format});
	$percent = ($hashref->{stake} > 0) ? $hashref->{under_winnings} / $hashref->{stake} - 1 : 0;
	$worksheet->write ($row, $col, $percent, $self->get_format ($percent));

	$col += 2;
	$worksheet->write ($row, $col ++, $hashref->{fav_winnings}, $self->{currency_format});
	$percent = ($hashref->{stake} > 0) ? $hashref->{fav_winnings} / $hashref->{stake} - 1 : 0;
	$worksheet->write ($row, $col, $percent, $self->get_format ($percent));

	$col += 2;
	$worksheet->write ($row, $col ++, $hashref->{draw_winnings}, $self->{currency_format});
	$percent = ($hashref->{stake} > 0) ? $hashref->{draw_winnings} / $hashref->{stake} - 1 : 0;
	$worksheet->write ($row, $col, $percent, $self->get_format ($percent));
}

sub get_format {
	my ($self, $percent) = @_;
	return ( $percent > 0 ) ? $self->{highlight_percent_format} : $self->{percent_format};
}

1;
