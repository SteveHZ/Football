package Euro::Spreadsheets::Match_Odds_View;

#	Euro::Spreadsheets::Match_Odds_View.pm 26/07/17

use Football::Globals qw($reports_folder @euro_csv_lgs);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$reports_folder/Match Odds Euro.xlsx";
}

sub get_csv_league {
	my ($self, $league_idx) = @_;
	return $euro_csv_lgs [$league_idx];
}

1;
