package Summer::Spreadsheets::Goal_Diffs_View;

#	Summer::Spreadsheets::Goal_Diffs_View 12/03/18

use parent 'Football::Spreadsheets::Goal_Diffs_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'goal_diffs.xlsx';
}

1;