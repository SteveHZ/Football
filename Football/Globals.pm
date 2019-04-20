package Football::Globals;

use strict;
use warnings;
use MyKeyword qw(TESTING);

use Exporter 'import';

use vars qw (@EXPORT_OK %EXPORT_TAGS);

our @EXPORT = qw(
	$season
	$next_season
	$euro_season
	$season_years
	$full_season_years
	$last_season
	$reports_season
	$default_stats_size
	@league_names
	@fixtures_leagues
	@csv_leagues
	@fixtures_csv_leagues
	@league_size
	@euro_leagues
	@euro_csv_leagues
	@euro_lgs
	@euro_csv_lgs
	@euro_fetch_lgs
	@summer_leagues
	@summer_csv_leagues
	@summer_fetch_leagues
	$max_skellam
	$min_skellam
);

%EXPORT_TAGS = (all => \@EXPORT);

sub new { return bless {}, shift; }

our $season = 2018;
our $euro_season = 2019;

our $next_season = $season + 1;
our $season_years = ($season-2000).($next_season-2000);
our $full_season_years = "$season-$next_season";
our $last_season = $season - 1;
our $reports_season = $last_season;
our $default_stats_size = 6;

our @league_names = (
	'Premier League',
	'Championship',
	'League One',
	'League Two',
	'Conference',
	'Scots Premier',
	'Scots Championship',
	'Scots League One',
	'Scots League Two',
);

our @fixtures_leagues = (
	'Premier League',
	'Championship',
	'League One',
	'League Two',
	'Conference',
	'Scots Premier',
	'Scots Championship',
	'Scots League One',
	'Scots League Two',
);

our @csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 );
our @fixtures_csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 );
our @league_size = qw( 20 24 24 24 24 12 10 10 10 ); # clubs in each league

# for euro.pl

our @euro_leagues = (
	'English Premier League', 'English Championship', 'English League One', 'English League Two', 'English Conference',
	'Scots Premier League', 'Scots Championship', 'Scots League One', 'Scots League Two',
	'German League One', 'German League Two', 'Spanish League One', 'Spanish League Two',
	'Italian League One', 'Italian League Two', 'French League One', 'French League Two',
	'Dutch League One', 'Belgian League One', 'Portuguese League One', 'Turkish League One',
	'Greek League One',
);

our @euro_csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 D1 D2 SP1 SP2 I1 I2 F1 F2 N1 B1 P1 T1 G1 );

# for max_profit.pl, db.pl and fetch.pl

our @euro_lgs = ('German', 'Spanish', 'Italian', 'Welsh', 'N Irish');
our @euro_csv_lgs = qw( D1 SP1 I1 WL NI);
our @euro_fetch_lgs = qw( D1 SP1 I1);

# enable TESTING/else blocks to reduce number of leagues used at start/end of season_data
# while still ensuring test scripts will pass
TESTING { # Do not touch these lines
	our @summer_leagues = ('Irish League', 'USA League', 'Swedish League', 'Norwegian League', 'Finnish League');
	our @summer_csv_leagues = qw(ROI MLS SWD NRW FN);
	our @summer_fetch_leagues = qw(IRL USA SWE NOR FIN);
} else { # Amend these lines as needed
#our @summer_leagues = ('Irish League', 'USA League', 'Swedish League', 'Norwegian League');
#our @summer_csv_leagues = qw(ROI MLS SWD NRW);
	our @summer_leagues = ('Irish League', 'USA League', 'Swedish League', 'Norwegian League', 'Finnish League');
	our @summer_csv_leagues = qw(ROI MLS SWD NRW FN);
	our @summer_fetch_leagues = qw(IRL USA SWE NOR FIN);
}

=pod

=head1 NAME

Football::Globals.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
