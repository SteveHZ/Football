package Rugby::Globals;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
	$season
	$reports_start
	@league_size
	@league_names
	@fixtures_leagues
	@csv_leagues
	@fixtures_csv_leagues
);

sub new { return bless {}; shift; }

my $regular_season = 1;
$regular_season = 0; # unquote for later season

our $season = 2017;
our $reports_start = 2016;

if ($regular_season) {
	our @league_names = (
		"Super League",
		"Championship",
		"League One",
		"NRL",
	);

	our @fixtures_leagues = (
		"Super League",
		"Championship",
		"NRL",
		"League One",
	);

	our @csv_leagues = qw(SL CH L1 NRL);
	our @fixtures_csv_leagues = qw(SL CH NRL L1);
	our @league_size = qw( 12 12 16 16 ); # clubs in each league

} else {

	our @league_names = (
		"Super League",
		"Middle 8s",
		"Championship",
		"League One",
		"NRL",
	);

	our @fixtures_leagues = (
		"Super League",
		"Middle 8s",
		"Championship",
		"NRL",
		"League One",
	);

	our @csv_leagues = qw(SL M8 CH L1 NRL);
	our @fixtures_csv_leagues = qw(SL M8 CH NRL L1);
	our @league_size = qw( 12 8 12 16 16 ); # clubs in each league
}

1;
