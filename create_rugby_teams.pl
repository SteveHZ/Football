#!	C:/Strawberry/perl/bin

#	create_rugby_teams.pl 23/07/16
#	When updating to Middle 8s, need to leave teams within their original league as well

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

my $path = 'C:/Mine/perl/Football/data/Rugby/';
my $json_file = $path.'teams.json';

my $leagues = {
	'Super League' => [
		'Castleford Tigers',
		'Hull FC',
		'St Helens',
		'Wakefield Trinity',
		'Wigan Warriors',
		'Leeds Rhinos',
		'Huddersfield',
		'Salford Red Devils',
		'Warrington Wolves',
		'Catalans Dragons',
		'Widnes Vikings',
		'Hull KR',
	],
	'Championship' => [
		'Batley',
		'Dewsbury Rams',
		'Sheffield',
		'Swinton',
		'Rochdale Hornets',
		'Toulouse Olympique',
		'London Broncos',
		'Halifax',
		'Featherstone Rovers',
		'Leigh Centurions',
		'Toronto Wolfpack',
		'Barrow Raiders',
	],
#	'Middle 8s' => [
#		'Warrington Wolves',
#		'Catalans Dragons',
#		'Leigh Centurions',
#		'Widnes Vikings',
#		'Hull KR',
#		'London Broncos',
#		'Halifax',
#		'Featherstone Rovers',
#	],
	'League One' => [
		'London Skolars',
		'York City Knights',
		'Hemel Stags',
		'Doncaster',
		'Coventry Bears',
		'Hunslet Hawks',
		'Keighley Cougars',
		'North Wales Crusaders',
		'West Wales Raiders',
		'Whitehaven',
		'Workington Town',
		'Newcastle Thunder',
		'Bradford Bulls',
		'Oldham',
	],
#	'NRL' => [
#		'South Sydney Rabbitohs',
#		'Cronulla Sharks',
#		'Sydney Roosters',
#		'St.George Illawarra',
#		'Canberra Raiders',
#		'Parramatta Eels',
#		'North Queensland Cowboys',
#		'New Zealand Warriors',
#		'Manly Sea Eagles',
#		'Melbourne Storm',
#		'Newcastle Knights',
#		'Gold Coast Titans',
#		'Penrith Panthers',
#		'Wests Tigers',
#		'Brisbane Broncos',
#		'Canterbury Bulldogs',
#	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "\nDone";

=pod

=head1 NAME

perl create_rugby_teams.pl

=head1 SYNOPSIS

perl create_rugby_teams.pl

=head1 DESCRIPTION

Create Rugby/teams.json file

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
