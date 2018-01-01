package Rugby::Spreadsheets::Reports;

#	Spreadsheets::Reports.pm 01/03/16 - 13/04/16
#	v1.2 06/05/17, 29/06/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

extends 'Football::Spreadsheets::Reports';

sub get_path {
	return 'C:/Mine/perl/Football/reports/Rugby/';
}

1;
