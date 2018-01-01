package Euro::Spreadsheets::Tables;

#	Euro::Spreadsheets::Tables.pm 27/06/17

use parent 'Football::Spreadsheets::Tables';

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/Euro/tables/';
	$self->{filename} = $path.$filename.'.xlsx';
}

1;