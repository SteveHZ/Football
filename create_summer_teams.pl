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

use Football::Globals qw(@summer_leagues);
use Football::TeamsList;

my $path = 'C:/Mine/perl/Football/data/Summer/';
my $json_file = $path.'teams.json';

my $leagues = {
    'Irish League' => [
        'Bohemians',
        'Cork City',
        'Derry City',
        'Dundalk',
        'Finn Harps',
        'Shamrock Rovers',
        'Sligo Rovers',
        'St Patricks',
        'UCD',
        'Waterford',
    ],
    'USA League' => [
        'Atlanta United',
        'Chicago Fire',
        'Cincinnati',
        'Colorado Rapids',
        'Columbus Crew',
        'DC United',
        'FC Dallas',
        'Houston Dynamo',
        'LA Galaxy',
        'Los Angeles FC',
        'Minnesota',
        'Montreal Impact',
        'New England Revolution',
        'New York City',
        'New York Red Bulls',
        'Orlando City',
        'Philadelphia Union',
        'Portland Timbers',
        'Real Salt Lake',
        'San Jose Earthquakes',
        'Seattle Sounders',
        'Sporting Kansas City',
        'Toronto FC',
        'Vancouver Whitecaps',
    ],
    'Swedish League' => [
        'AFC Eskilstuna',
        'AIK',
        'Djurgardens',
        'Elfsborg',
        'Falkenbergs',
        'Goteborg',
        'Hacken',
        'Hammarby',
        'Helsingborg',
        'Kalmar',
        'Malmo',
        'Norrkoping',
        'Orebro',
        'Ostersunds',
        'Sirius',
        'Sundsvall',
    ],
    'Norwegian League' => [
        'Bodo Glimt',
        'Brann',
        'Haugesund',
        'Kristiansund',
        'Lillestrom',
        'Mjondalen',
        'Molde',
        'Odd',
        'Ranheim',
        'Rosenborg',
        'Sarpsborg',
        'Stabaek',
        'Stromsgodset',
        'Tromso',
        'Valerenga',
        'Viking',
    ],
    'Finnish League' => [
        'HIFK Helsinki',
        'HJK Helsinki',
        'Honka',
        'Ilves',
        'Inter Turku',
        'KPV Kokkola',
        'KuPS Kuopio',
        'Lahti',
        'Mariehamn',
        'Rovaniemi',
        'SJK',
        'VPS Vaasa',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

my $out_file = 'data/teams/summer_teams.pl';
print "\nWriting new sorted team list to $out_file...";

my $team_list = Football::TeamsList->new (
	leagues => \@summer_leagues,
	sorted => $sorted,
	filename => $out_file,
);
$team_list->create ();
