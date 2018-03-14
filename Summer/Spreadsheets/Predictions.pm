package Summer::Spreadsheets::Predictions;

#	Summer::Spreadsheets::Predictions.pm 12/03/18

use parent 'Football::Spreadsheets::Predictions';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'predictions.xlsx';
}

1;