package Summer::Spreadsheets::Skellam_Dist_View;

# 	Summer::Spreadsheets::Skellam_Dist_View 12/03/18

use parent 'Football::Spreadsheets::Skellam_Dist_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'skellam.xlsx';
}

1;