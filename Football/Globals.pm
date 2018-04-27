package Football::Globals;

use strict;
use warnings;

use Exporter 'import';

use vars qw (@EXPORT_OK %EXPORT_TAGS);

our @EXPORT = qw(
	$season
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
	$max_skellam
	$min_skellam
);

%EXPORT_TAGS = (all => \@EXPORT);

sub new { return bless {}, shift; }

our $season = 2017;
our $euro_season = 2018;
our $season_years = 1718;
our $full_season_years = '2017-2018';
our $last_season = $season - 1;
our $reports_season = 2016;
our $default_stats_size = 6;

our @league_names = (
	"Premier League",
	"Championship",
	"League One",
	"League Two",
	"Conference",
	"Scots Premier",
	"Scots Championship",
	"Scots League One",
	"Scots League Two",
);

our @fixtures_leagues = (
	"Premier League",
	"Championship",
	"League One",
	"League Two",
	"Conference",
	"Scots Premier",
	"Scots Championship",
	"Scots League One",
	"Scots League Two",
);

our @csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 );
our @fixtures_csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 );
our @league_size = qw( 20 24 24 24 24 12 10 10 10 ); # clubs in each league

# for euro.pl

our @euro_leagues = (
	"English Premier League", "English Championship", "English League One", "English League Two", "English Conference",
	"Scots Premier League", "Scots Championship", "Scots League One", "Scots League Two",
	"German League One", "German League Two", "Spanish League One", "Spanish League Two",
	"Italian League One", "Italian League Two", "French League One", "French League Two",
	"Dutch League One", "Belgian League One", "Portuguese League One", "Turkish League One",
	"Greek League One",
);

our @euro_csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 D1 D2 SP1 SP2 I1 I2 F1 F2 N1 B1 P1 T1 G1 );

# for max_profit.pl and db.pl

our @euro_lgs = ("German 1", "German 2", "Spanish 1", "Italian 1", "Welsh", "N Irish");
our @euro_csv_lgs = qw( D1 D2 SP1 I1 WL NI);

our @summer_leagues = ("Irish_League", "Norwegian_League");
#our @summer_leagues = ("Irish League", "Norwegian League", "Swedish League", "USA League");

# for fetch.pl

our @euro_fetch_lgs = qw( D1 D2 SP1 I1);

#	%euro_odds_cols
#our %euro_odds_cols = (
#	E0  => 23, E1  => 23, E2  => 23, E3  => 23, EC => 15,
#	SC0 => 23, SC1 => 23, SC2 => 23, SC3 => 23,
#	D1  => 22, D2  => 22, SP1 => 22, SP2 => 22,
#	I1  => 22, I2  => 22, F1  => 22, F2  => 22,
#	N1  => 22, B1  => 22, P1  => 22, T1  => 22, G1 => 22,
#);
#our @summer_leagues = (
#	"Welsh League",
#	"Northern Irish League",
#	"Swedish League",
#	"Norwegian League",
#	"Irish League",
#	"USA League",
#);

#our @summer_csv_leagues = qw( WL NIL );
#our @summer_csv_leagues = qw( WL IL NIL SL NL AL );
#my leagues = [ qw(Swedish Norwegian Irish American) ];

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