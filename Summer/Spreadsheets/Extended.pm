package Summer::Spreadsheets::Extended;

#	Summer::Spreadsheets::Extended 12/03/18

use parent 'Football::Spreadsheets::Extended';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'extended.xlsx';
}

1;
