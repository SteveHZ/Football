
#	acca_sheet.pl 7-11/02/17
#	max profit sheet 04/02/18

use strict;
use warnings;

package Accumulator;

use utf8;
use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->{filename} = $args->{filename};
}

after 'BUILD' => sub {
	my $self = shift;

	$self->{bold_format}->set_color ('blue');
	$self->{currency_format}->set_color ('black');
	$self->{currency_format}->set_bg_color ('white');
	$self->{percent_format}->set_color ('black');
	$self->{percent_format}->set_bg_color ('white');

	$self->{text_format} = $self->{workbook}->add_format (
		align => 'center',
		num_format => '@',
	);
	$self->{date_format} = $self->{workbook}->add_format (
		align => 'center',
		num_format => 'DD/MM/YY',
	);
};

sub do_header {
	my ($self, $worksheet, $format) = @_;

	my $profit_format = $self->copy_format ($format);
	$profit_format->set_color ('orange');

	$worksheet->write ('B1', 'Wins', $format);
	$worksheet->merge_range ('C1:D1', 'Singles', $format);
	$worksheet->write ('E1', 'ROI', $format);
	$worksheet->write ('G1', 'Stake', $format);
	$worksheet->write ('H1', 'Return', $format);
	$worksheet->merge_range ('I1:J1', 'Profit', $profit_format);

	$worksheet->set_column ('A:A', 10, $self->{date_format} );
	$worksheet->set_column ('B:B', 10, $self->{text_format} );
	$worksheet->set_column ('C:I', 10, $self->{currency_format} );
	$worksheet->set_column ('E:E', 10, $self->{percent_format} );
	$worksheet->set_column ('G:I', 10, $self->{currency_format} );
	$worksheet->set_column ('J:J', 10, $self->{percent_format} );
	$worksheet->set_column ('L:L', 10, $self->{currency_format} );
}

sub write_sheet {
	my ($self, $worksheet) = @_;
	my $start = 2;
	my @cols = (4,6,7,8,9,11);

	for my $row (2..300) {
		my $prev = $row - 1;
		my @formulas = ( #	DO NOT CHANGE QUOTES TO SINGLE QUOTES !!
			qq(=IF(D$row <> "", ((D$row-C$row)/C$row), "")),
			qq(=IF(C$row <> "", SUM(C$start:C$row), "")),
			qq(=IF(D$row <> "", SUM(D$start:D$row), "")),
			qq(=IF(H$row <> "", H$row - G$row, "")),
			qq(=IF(H$row <> "", I$row / G$row, "")),
			qq(=IF(G$row <> "", L$prev - C$row + D$row, "")),
		);

		for my $idx (0..$#cols) {
			$worksheet->write ($row - 1, $cols[$idx], $formulas[$idx]);
		}
	}
}

sub write {
	my $self = shift;
	my $worksheet = $self->add_worksheet ('Football');
	$self->do_header ($worksheet, $self->{bold_format});
	$self->write_sheet ($worksheet);
}

package main;

my $sheet = Accumulator->new (filename => 'accas.xlsx');
$sheet->write();

print 'Done';
