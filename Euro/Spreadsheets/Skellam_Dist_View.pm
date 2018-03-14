package Euro::Spreadsheets::Skellam_Dist_View;

use parent 'Football::Spreadsheets::Skellam_Dist_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'skellam.xlsx';
}

1;