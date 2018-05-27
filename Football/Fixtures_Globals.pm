package Football::Fixtures_Globals;

use strict;
use warnings;

use Exporter 'import';

use vars qw (@EXPORT_OK %EXPORT_TAGS);

our @EXPORT = qw(
	%bbc_fixtures_leagues
	%fixtures_rename
);
@EXPORT_OK  = qw( fixture_rename );
%EXPORT_TAGS = (all => [ @EXPORT, @EXPORT_OK ]);

sub new { return bless {}, shift; }

our %bbc_fixtures_leagues = (
	'Welsh Premier League' => 'WL',
	'Irish Premiership' => 'NI',
	'Premier League' => 'E0',
	'Championship' => 'EC',
	'League One' => 'E2',
	'League Two' => 'E3',
	'National League' => 'EC',
	'Scottish Premiership' => 'SC0',
	'Scottish Championship' => 'SC1',
	'Scottish League One' => 'SC2',
	'Scottish League Two' => 'SC3',
	'Spanish La Liga' => 'SP1',
	'Italian Serie A' => 'I1',
	'Irish Premier Division' => 'ROI',
	'Norwegian Eliteserien' => 'NRW',
	'Swedish Allsvenskan' => 'SWD',
	'Finnish Veikkausliiga' => 'FN',
	'United States Major League Soccer' => 'MLS',
	'Russian Premier League' => 'X',
	'Swiss Super League' => 'X',
	'Women\'s Super League 1' => 'X',
);

our %fixtures_rename = (
#	Irish
	"St Patrick's Athletic" => 'St Patricks',
#	American
	'D.C. United' => 'DC United',
	'Minnesota United FC' => 'Minnesota',
	'Atlanta United FC' => 'Atlanta United',
	'New York City FC' => 'New York City',
	'Seattle Sounders FC' => 'Seattle Sounders',
	'Vancouver Whitecaps FC' => 'Vancouver Whitecaps',
	'Los Angeles Football Club' => 'Los Angeles FC',
);

sub fixture_rename {
	my $name = shift;
	return unless defined $name;
	return defined $fixtures_rename{ $name }
		? $fixtures_rename{ $name } : $name;
}

=pod

=head1 NAME

Football::Fixture_Globals.pm

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