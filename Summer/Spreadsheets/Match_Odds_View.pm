package Summer::Spreadsheets::Match_Odds_View;

#	Summer::Spreadsheets::Match_Odds_View.pm 12/03/18

use Football::Globals qw($cloud_folder @summer_csv_leagues);

use Moo;
use namespace::clean;

extends 'Football::Spreadsheets::Match_Odds_View';

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$cloud_folder/Match Odds Summer.xlsx";
}

sub get_csv_league {
	my ($self, $league_idx) = @_;
	return $summer_csv_leagues [$league_idx];
}

1;