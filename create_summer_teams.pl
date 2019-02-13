#!	C:/Strawberry/perl/bin

#	create_euro_teams.pl 26/06/16
#	Irish + USA teams updated 05.02 but need to check against Football Data site
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
		'Dalkurd',
		'Brommapojkarna',
		'Trelleborgs',
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
		'Sandefjord',
		'Bodo Glimt',
		'Start',
		'Ranheim',
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
		'PS Kemi',
		'TPS Turku',
		'Ilves',
		'Honka',
		'Mariehamn',
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "\nDone";
