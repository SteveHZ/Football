package Rugby::Spreadsheets::Extended;

#	Rugby::Spreadsheets::Extended.pm 19/04/16
#	v1.1 06/05/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

extends 'Football::Spreadsheets::Extended';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/';
	$self->{filename} = $path.'extended.xlsx';
}

1;
