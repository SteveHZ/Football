#	create_summer_teams.pl 26/06/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals, Football::Fixtures_Model

# All leagues updated for 2020 14/03/20

use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

use Football::Globals qw(@summer_leagues);

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
        'Shelbourne',
        'Sligo Rovers',
        'St Patricks',
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
        'Inter Miami',
        'LA Galaxy',
        'Los Angeles FC',
        'Minnesota',
        'Montreal Impact',
        'Nashville',
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
        'Mjallby',
        'Norrkoping',
        'Orebro',
        'Ostersunds',
        'Sirius',
        'Varbergs',
    ],
    'Norwegian League' => [
        'Aalesund',
        'Bodo Glimt',
        'Brann',
        'Haugesund',
        'Kristiansund',
        'Mjondalen',
        'Molde',
        'Odd',
        'Rosenborg',
        'Sandefjord',
        'Sarpsborg',
        'Stabaek',
        'Start',
        'Stromsgodset',
        'Valerenga',
        'Viking',
    ],
    'Finnish League' => [
        'HIFK Helsinki',
        'HJK Helsinki',
        'Haka',
        'Honka',
        'Ilves',
        'Inter Turku',
        'KuPS Kuopio',
        'Lahti',
        'Mariehamn',
        'Rovaniemi',
        'SJK',
        'TPS Turku',
    ],
    'Brazilian League' => [
        'Athletico Paranaense',
        'Atletico Goianiense',
        'Atletico Mineiro',
        'Bahia',
        'Botafogo',
        'Ceara',
        'Corinthians',
        'Coritba',
        'Flamengo',
        'Fluminense',
        'Fortaleza',
        'Goias',
        'Gremio',
        'Internacional',
        'Palmeiras',
        'Red Bull Bragantino',
        'Santos',
        'Sao Paulo',
        'Sport',
        'Vasco da Gama',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

my $out_file = 'data/teams/summer_teams.pl';
my $tt = MyTemplate->new (
    filename => $out_file,
    template => 'Template/create_new_teams.tt',
    data => {
        leagues => \@summer_leagues,
        sorted => $sorted,
    },
);
print "\nWriting new sorted team list to $out_file...";
$tt->write_file ();

print " Done";
