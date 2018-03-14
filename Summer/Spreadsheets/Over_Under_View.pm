package Summer::Spreadsheets::Over_Under_View;

#	Summer::Spreadsheets::Over_Under_View.pm 12/03/18

use parent 'Football::Spreadsheets::Over_Under_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'over_under.xlsx';
}

1;