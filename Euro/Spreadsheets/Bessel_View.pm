package Euro::Spreadsheets::Bessel_View;

use Moo;
use namespace::clean;

use parent 'Football::Spreadsheets::Bessel_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'bessel.xlsx';
}

1;