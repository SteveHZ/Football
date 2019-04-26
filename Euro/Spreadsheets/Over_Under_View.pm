package Euro::Spreadsheets::Over_Under_View;

#	Euro::Spreadsheets::Over_Under_View.pm 26/07/17

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Over_Under_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'over_under.xlsx';
}

1;
