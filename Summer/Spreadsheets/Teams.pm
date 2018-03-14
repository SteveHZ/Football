package Summer::Spreadsheets::Teams;

#	Summer::Spreadsheets::Teams.pm 12/03/18

use parent 'Football::Spreadsheets::Teams';

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/Summer/divisions/';
	$self->{filename} = $path.$filename.'.xlsx';
}

1;