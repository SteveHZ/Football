package Euro::Spreadsheets::Match_Odds_View;

#	Euro::Spreadsheets::Match_Odds_View.pm 26/07/17

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Users/Steve/Dropbox/Football/';
	$self->{filename} = $path.'Match Odds Euro.xlsx';
}

1;
