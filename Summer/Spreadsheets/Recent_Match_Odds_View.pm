package Summer::Spreadsheets::Recent_Match_Odds_View;

#	Summer::Spreadsheets::Recent_Match_Odds_View.pm 15/04/22

use Football::Globals qw($cloud_folder);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Recent_Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$cloud_folder/Recent Match Odds Summer.xlsx";
}

1;