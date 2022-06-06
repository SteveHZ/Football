package Summer::Spreadsheets::Match_Odds_View;

#	Summer::Spreadsheets::Match_Odds_View.pm 12/03/18

use Football::Globals qw($cloud_folder);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$cloud_folder/Match Odds Summer.xlsx";
}

1;