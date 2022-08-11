package Euro::Spreadsheets::Match_Odds_View;

#	Euro::Spreadsheets::Match_Odds_View.pm 26/07/17

use Football::Globals qw($cloud_folder @euro_csv_leagues);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$cloud_folder/Match Odds Euro.xlsx";
}

sub get_csv_league {
	my ($self, $league_idx) = @_;
	return $euro_csv_leagues [$league_idx];
}

1;
