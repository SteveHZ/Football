package Rugby::Spreadsheets::Predictions;

#	Predictions.pm 07/02/16 - 15/03/16
# 	Rugby version 03/05/16, v2.1 02/04/17
#	v2.2 06/05/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

extends 'Football::Spreadsheets::Predictions';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/';
	$self->{filename} = $path.'predictions.xlsx';
}

1;
