package Euro::Spreadsheets::Predictions;

#	Euro::Spreadsheets::Predictions.pm 27/06/17

use parent 'Football::Spreadsheets::Predictions';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'predictions.xlsx';
}

1;