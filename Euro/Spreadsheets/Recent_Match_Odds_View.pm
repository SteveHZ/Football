package Euro::Spreadsheets::Recent_Match_Odds_View;

#	Euro::Spreadsheets::Recent_Match_Odds_View.pm 15/04/22

use Football::Globals qw($reports_folder);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Recent_Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$reports_folder/Recent Match Odds Euro.xlsx";
}

1;
