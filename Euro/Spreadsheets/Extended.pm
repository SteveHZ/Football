package Euro::Spreadsheets::Extended;

#	Euro::Spreadsheets::Extended.pm 27/06/17

use parent 'Football::Spreadsheets::Extended';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'extended.xlsx';
}

1;
