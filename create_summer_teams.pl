#	create_summer_teams.pl 26/06/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals, Football::Fixtures_Model

#	Irish + USA teams updated 05.02 but need to check against Football Data site
#	All done except Finnish 03/04, Finnish 10/04

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

my $path = 'C:/Mine/perl/Football/data/Summer/';
my $json_file = $path.'teams.json';

my $leagues = {
	'Irish League' => [
		'Dundalk',
		'St Patricks',
		'Bohemians',
		'Cork City',
		'Shamrock Rovers',
		'Sligo Rovers',
		'Derry City',
		'Waterford',
		'UCD',
		'Finn Harps',
	],
	'Swedish League' => [
		'Goteborg',
		'Norrkoping',
		'Sundsvall',
		'AIK',
		'Orebro',
		'Kalmar',
		'Djurgardens',
		'Ostersunds',
		'Malmo',
		'Hammarby',
		'Hacken',
		'Elfsborg',
		'Sirius',
		'Falkenbergs',
		'AFC Eskilstuna',
		'Helsingborg',
	],
	'Norwegian League' => [
		'Kristiansund',
		'Rosenborg',
		'Tromso',
		'Stromsgodset',
		'Stabaek',
		'Sarpsborg',
		'Lillestrom',
		'Valerenga',
		'Molde',
		'Odd',
		'Brann',
		'Haugesund',
		'Bodo Glimt',
		'Ranheim',
		'Mjondalen',
		'Viking',
	],
	'USA League' => [
		'Portland Timbers',
		'Minnesota',
		'Chicago Fire',
		'Columbus Crew',
		'LA Galaxy',
		'Los Angeles FC',
		'FC Dallas',
		'Toronto FC',
		'Real Salt Lake',
		'Colorado Rapids',
		'New England Revolution',
		'Sporting Kansas City',
		'DC United',
		'Houston Dynamo',
		'Seattle Sounders',
		'Montreal Impact',
		'San Jose Earthquakes',
		'Orlando City',
		'New York City',
		'New York Red Bulls',
		'Atlanta United',
		'Vancouver Whitecaps',
		'Philadelphia Union',
		'Cincinnati',
	],
	'Finnish League' => [
		'Rovaniemi',
		'VPS Vaasa',
		'SJK',
		'Lahti',
		'HJK Helsinki',
		'KuPS Kuopio',
		'Inter Turku',
		'Ilves',
		'Honka',
		'Mariehamn',
		'HIFK Helsinki',
		'KPV Kokkola',
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "\nDone";
