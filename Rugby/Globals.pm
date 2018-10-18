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
	@rugby_csv_leagues
	@fixtures_csv_leagues
);

sub new { return bless {}; shift; }

our $season = 2018;
our $results_season = substr $season,2,2;
our $reports_start = 2016;

our @league_names = (
	'Super League',
	'Championship',
	'League One',
	'NRL',
);

our @fixtures_leagues = (
	'Super League',
	'Championship',
	'League 1',
	'NRL',
);

our @rugby_csv_leagues = qw(SL CH L1 NRL);
our @fixtures_csv_leagues = qw(SL CH L1 NRL);
our @league_size = qw( 12 12 14 16 ); # clubs in each league

1;
