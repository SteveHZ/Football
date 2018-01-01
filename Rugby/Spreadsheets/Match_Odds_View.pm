package Rugby::Spreadsheets::Match_Odds_View;

#	Rugby::Spreadsheets::Match_Odds_View.pm 09/12/17

use parent 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/';
	$self->{filename} = $path.'match_odds.xlsx';
}

1;