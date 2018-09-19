package Rugby::Globals;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
	$season
	$results_season
	$reports_start
	@league_size
	@league_names
	@fixtures_leagues
	@csv_leagues
	@fixtures_csv_leagues
);

sub new { return bless {}; shift; }

my $regular_season = 1;
#$regular_season = 0; # unquote for later season

our $season = 2018;
our $results_season = substr $season,2,2;
our $reports_start = 2016;

if ($regular_season) {
	our @league_names = (
		'Super League',
		'Championship',
		'League One',
#		'NRL',
	);

	our @fixtures_leagues = (
		'Super League',
		'Championship',
		'League 1',
#		'NRL',
	);

	our @csv_leagues = qw(SL CH L1);
	our @fixtures_csv_leagues = qw(SL CH L1);
	our @league_size = qw( 12 12 14 ); # clubs in each league

} else {

	our @league_names = (
		'Super League',
		'Middle 8s',
		'Championship',
		'League One',
#		'NRL',
	);

	our @fixtures_leagues = (
		'Super League',
		'Middle 8s',
		'Championship',
		'League 1',
#		'NRL',
	);

	our @csv_leagues = qw(SL M8 CH L1);
	our @fixtures_csv_leagues = qw(SL M8 CH L1);
	our @league_size = qw( 12 8 12 14 ); # clubs in each league
}

1;
