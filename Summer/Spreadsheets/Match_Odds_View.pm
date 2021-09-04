package Summer::Spreadsheets::Match_Odds_View;

#	Summer::Spreadsheets::Match_Odds_View.pm 12/03/18

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Users/Steve/Dropbox/Football/';
	$self->{filename} = $path.'Match Odds Summer.xlsx';
}

1;