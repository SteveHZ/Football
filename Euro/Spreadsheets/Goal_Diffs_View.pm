package Euro::Spreadsheets::Goal_Diffs_View;

#	Euro::Spreadsheets::Goal_Diffs_View.pm 26/07/17

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Goal_Diffs_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'goal_diffs.xlsx';
}

1;
