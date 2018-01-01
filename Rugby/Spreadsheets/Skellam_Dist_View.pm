package Rugby::Spreadsheets::Skellam_Dist_View;

#	Rugby::Spreadsheets::Skellam_Dist_View.pm 09/12/17

use parent 'Football::Spreadsheets::Skellam_Dist_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/';
	$self->{filename} = $path.'skellam.xlsx';
}

1;