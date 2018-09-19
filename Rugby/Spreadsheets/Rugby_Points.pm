package Rugby::Spreadsheets::Rugby_Points;

#	Rugby_Points.pm 23/05/16

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

my $path = 'C:/Mine/perl/Football/reports/Rugby/';
my $filename = 'rugby_points.xlsx';

sub BUILD {
	my $self = shift;
	$self->{filename} = $path.$filename;
}

sub do_rugby_points {
	my ($self, $hash, $range) = @_;

	print "\nWriting worksheet...";
	my $worksheet = $self->add_worksheet ('Rugby Points');
	do_header ($worksheet, $self->{bold_format});

	my $row = 1;
	for my $points_diff (@$range) {
		if ($hash->{$points_diff}) {
			$worksheet->write ($row, 0, $points_diff, $self->{format});
			$worksheet->write ($row, 2, $hash->{$points_diff}, $self->{format});
			$row ++;
		}
	}
	$self->{workbook}->close ();
}

sub do_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ($_, 20) for ('A:A');
	$worksheet->set_column ($_, 10) for ('C:C');
	$worksheet->set_column ($_, 5) for (qw (B:B D:D));

	$worksheet->write ('A1', 'Points Difference', $format);
	$worksheet->write ('C1', 'Games', $format);
}

1;
