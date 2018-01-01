package Rugby::Spreadsheets::Points_Diff_View;

#	Rugby::Spreadsheets::Points_Diff_View.pm 26/07/17

use parent 'Football::Spreadsheets::Goal_Diffs_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/';
	$self->{filename} = $path.'points_diff.xlsx';
}

1;