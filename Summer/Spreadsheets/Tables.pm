package Summer::Spreadsheets::Tables;

#	Summer::Spreadsheets::Tables.pm 12/03/18

use parent 'Football::Spreadsheets::Tables';

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/Summer/tables/';
	$self->{filename} = $path.$filename.'.xlsx';
}

1;