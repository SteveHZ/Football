package Summer::Spreadsheets::Match_Odds_View;

#	Summer::Spreadsheets::Match_Odds_View.pm 12/03/18

use parent 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'match_odds.xlsx';
}

1;