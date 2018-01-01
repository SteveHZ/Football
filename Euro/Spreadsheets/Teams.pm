package Euro::Spreadsheets::Teams;

#	Euro::Spreadsheets::Teams.pm 27/06/17

use parent 'Football::Spreadsheets::Teams';

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/Euro/divisions/';
	$self->{filename} = $path.$filename.'.xlsx';
}

1;