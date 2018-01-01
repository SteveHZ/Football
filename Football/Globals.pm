package Football::Globals;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw(
	$season
	$last_season
	$reports_season
	$default_stats_size
	@league_names
	@fixtures_leagues
	@csv_leagues
	@fixtures_csv_leagues
	@league_size
	@euro_leagues
	%euro_odds_cols
	@euro_csv_leagues
	@summer_leagues
	@summer_csv_leagues
	$month_names
	$short_month_names
	$max_skellam
	$min_skellam
);
#	$bollox

#sub bollox { my ($self,$name) = @_; return "\nFuck off $name !!";};
#our $bollox = sub { my $name = shift; return "\nFuck off $name !!";};

#our $bolloxy = sub { my ($self,$name) = @_; return "\nFuck off $name !!";};
#sub bolloxxx { my ($self,$name) = @_; return $bolloxy;};

sub new { return bless {}, shift; }

our $season = 2017;
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

our @euro_leagues = (
	"English Premier League", "English Championship", "English League One", "English League Two", "English Conference",
	"Scots Premier League", "Scots Championship", "Scots League One", "Scots League Two",
	"German League One", "German League Two", "Spanish League One", "Spanish League Two",
	"Italian League One", "Italian League Two", "French League One", "French League Two",
	"Dutch League One", "Belgian League One", "Portuguese League One", "Turkish League One",
	"Greek League One",
);

our %euro_odds_cols = (
	E0  => 23, E1  => 23, E2  => 23, E3  => 23, EC => 15,
	SC0 => 23, SC1 => 10, SC2 => 10, SC3 => 10,
	D1  => 22, D2  => 10, SP1 => 22, SP2 => 10,
	I1  => 22, I2  => 10, F1  => 22, F2  => 10,
	N1  => 10, B1  => 10, P1  => 10, T1  => 10, G1 => 10,
);

our @euro_csv_leagues = qw( E0 E1 E2 E3 EC SC0 SC1 SC2 SC3 D1 D2 SP1 SP2 I1 I2 F1 F2 N1 B1 P1 T1 G1 );

our @summer_leagues = (
	"Welsh League",
	"Northern Irish League",
#	"Swedish League",
#	"Norwegian League",
#	"Irish League",
#	"USA League",
);

our @summer_csv_leagues = qw( WL NIL );
#our @summer_csv_leagues = qw( WL IL NIL SL NL AL );

our $month_names = { 
	"January" => "01",
	"February" => "02",
	"March" => "03",
	"April" => "04",
	"May" => "05",
	"June" => "06",
	"July" => "07",
	"August" => "08",
	"September" => "09",
	"October" => 10,
	"November" => 11,
	"December" => 12,
};

our $short_month_names = { 
	"Jan" => "01",
	"Feb" => "02",
	"Mar" => "03",
	"Apr" => "04",
	"May" => "05",
	"Jun" => "06",
	"Jul" => "07",
	"Aug" => "08",
	"Sep" => "09",
	"Oct" => 10,
	"Nov" => 11,
	"Dec" => 12,
};

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