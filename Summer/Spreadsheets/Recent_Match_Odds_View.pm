package Summer::Spreadsheets::Recent_Match_Odds_View;

#	Summer::Spreadsheets::Recent_Match_Odds_View.pm 15/04/22

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Recent_Match_Odds_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Users/Steve/Dropbox/Football/';
	$self->{filename} = $path.'Recent_Match Odds Summer.xlsx';
}

1;