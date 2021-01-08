package Euro::Rename;

#	Euro::Rename.pm 20/07/17, 13/03/18
#	Amend downloaded team names from football-data or odds-portal

use strict;
use warnings;
use utf8;

use Exporter 'import';
use vars qw (@EXPORT_OK %EXPORT_TAGS);

our @EXPORT = qw( $euro_teams );
@EXPORT_OK  = qw( check_rename );
%EXPORT_TAGS = (all => [ @EXPORT, @EXPORT_OK ]);

sub new { return bless {}, shift; }

our $euro_teams = {
#	Welsh
	'Druids' => 'Cefn Druids',
	'Connahs Q.' => 'Connahs Quay',
	'Cardiff Metropolitan' => 'Cardiff MU',
	'Barry' => 'Barry Town',
	'Bala' => 'Bala Town',
	'Caernarfon' => 'Caernarfon Town',

#	Northern Irish
	'C. Rangers' => 'Carrick Rangers',

#	Irish
	'St. Patricks' => 'St Patricks',
	'Bray' => 'Bray Wanderers',
	'UC Dublin' => 'UCD',

#	Swedish
	'Malmo FF' => 'Malmo', # FF removed in Fixtures_Model ??
	'Djurgarden' => 'Djurgardens',

#	Norwegian
	'Bodo/Glimt' => 'Bodo Glimt',
	'Sarpsborg 08' => 'Sarpsborg',

#	Finnish
	'HJK' => 'HJK Helsinki',
	'TPS' => 'TPS Turku',
	'VPS' => 'VPS Vaasa',
	'KuPS' => 'KuPS Kuopio',
	'HIFK' => 'HIFK Helsinki',

#	American
	'Los Angeles Galaxy' => 'LA Galaxy',
	'Minnesota United' => 'Minnesota',
	'FC Cincinnati' => 'Cincinnati',
	'Atlanta Utd' => 'Atlanta United',
	'Inter Miami CF' => 'Inter Miami',

#	Australian
	'Western Sydney Wanderers FC' => 'Western Sydney Wdrs',
	'Melbourne City FC' => 'Melbourne City',
	'Western United FC' => 'Western United',
	'Brisbane Roar FC' => 'Brisbane Roar',

#	English
#	"King’s Lynn" => 'Kings Lynn',
#	"Milton Keynes Dons" => "MK Dons",
};

sub check_rename {
	my $name = shift;
	return unless defined $name;
	return defined $euro_teams->{ $name }
		? $euro_teams->{ $name }
		: $name;
}

=head
our $old_euro_teams = {
#	Norwegian
	"Lillestrøm" => "Lillestrom",
	"Stabæk" => "Stabak",
	"Strømsgodset" => "Stromsgodset",
	"Tromsø" => "Tromso",
	"Vålerenga" => "Valerenga",

#	Swedish
	"IFK Göteborg" => "IFK Goteborg",
	"Malmö FF" => "Malmo FF",
	"Östersunds FK" => "Ostersunds FK",
	"BK Häcken" => "BK Hacken",
	"AFC United" => "AFC Eskiltuna",
	"IFK Norrköping" => "IFK Norrkoping",
	"Djurgårdens IF" => "Djurgardens IF",
	"Örebro SK" => "Orebro SK",
	"Jönköpings Södra IF" => "Jonkopings Sodra IF",

#	Welsh
	"e New Saints" => "The New Saints",
	"marthen Town" => "Carmarthen Town",
	"Gap Connah"s Quay" => "Connah"s Quay Nomads",
};

our $rugby_teams = {
	"Barrow" => "Barrow Raiders",
	"Keighley" => "Keighley Cougars",
	"Hemel" => "Hemel Stags",
	"Coventry" => "Coventry Bears",
	"Oxford RLFC" => "Oxford",
	"Newcastle" => "Newcastle Thunder",
	"Crusaders" => "North Wales Crusaders",
	"York City" => "York City Knights",
	"South Wales" => "South Wales Ironmen",
	"Hunslet RLFC" => "Hunslet Hawks",
	"Gloucestershire" => "Gloucestershire All Golds",
};
=cut

=pod

=head1 NAME

Euro::Rename.pm

=head1 SYNOPSIS

Used by max_profit.pl and euro_results.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
