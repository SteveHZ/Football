#!	C:/Strawberry/perl/bin

#	create_rugby_teams.pl 23/07/16
#	2019 season done 04/12/18

#	This file is for team names to be used within predict.pl
#???To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

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
		'Hull KR',
		'London Broncos',
	],
	'Championship' => [
		'Batley',
		'Dewsbury Rams',
		'Sheffield',
		'Swinton',
		'Rochdale Hornets',
		'Toulouse Olympique',
		'Halifax',
		'Featherstone Rovers',
		'Leigh Centurions',
		'Toronto Wolfpack',
		'Barrow Raiders',
		'Bradford Bulls',
		'York City Knights',
		'Widnes Vikings',
	],
	'League One' => [
		'London Skolars',
		'Doncaster',
		'Coventry Bears',
		'Hunslet Hawks',
		'Keighley Cougars',
		'North Wales Crusaders',
		'West Wales Raiders',
		'Whitehaven',
		'Workington Town',
		'Newcastle Thunder',
		'Oldham',
	],
	'NRL' => [
		'South Sydney Rabbitohs',
		'Cronulla Sharks',
		'Sydney Roosters',
		'St.George Illawarra',
		'Canberra Raiders',
		'Parramatta Eels',
		'North Queensland Cowboys',
		'New Zealand Warriors',
		'Manly Sea Eagles',
		'Melbourne Storm',
		'Newcastle Knights',
		'Gold Coast Titans',
		'Penrith Panthers',
		'Wests Tigers',
		'Brisbane Broncos',
		'Canterbury Bulldogs',
	],
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
