package Euro::Spreadsheets::Match_Odds_View;

#	Euro::Spreadsheets::Match_Odds_View.pm 26/07/17

use parent 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Euro/';
	$self->{filename} = $path.'match_odds.xlsx';
}

1;