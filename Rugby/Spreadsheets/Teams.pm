package Rugby::Spreadsheets::Teams;

#	Teams.pm 07/02/16
#	v1.1 06/05/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

extends 'Football::Spreadsheets::Teams';

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/divisions/';
	$self->{filename} = $path.$filename.'.xlsx';
}

sub set_columns {
	my ($self, $worksheet) = @_;
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('B:C', 10);
}

1;
