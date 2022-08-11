#	create_summer_teams.pl 26/06/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename or Football::Fetch_Amend for UK teams
#	To edit names from BBC fixtures files use Football::Fixtures_Globals, Football::Fixtures_Model

#	DEPRECATED 10/08/22 : To edit names from Football Data CSV files, use Euro::Rename

use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use Football::Globals qw(@summer_leagues @summer_csv_leagues);
use List::MoreUtils qw(each_array);

my $path = 'C:/Mine/perl/Football/data/Summer/';
my $json_file = $path.'teams.json';

my $leagues = {
    'Irish League' => [
        'Bohemians',
        'Derry City',
        'Drogheda',
        'Dundalk',
        'Finn Harps',
        'Shamrock Rvs',
        'Shelbourne',
        'Sligo Rvs',
        'St Patricks',
        'UCD',
    ],
    'USA League' => [
        'Atlanta United',
        'Austin FC',
        'Charlotte',
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
        'Montreal',
        'Nashville',
        'New England Rev',
        'New York City',
        'New York RB',
        'Orlando City',
        'Philadelphia',
        'Portland Timbers',
        'Real Salt Lake',
        'San Jose',
        'Seattle Sounders',
        'Sporting Kansas',
        'Toronto FC',
        'Vancouver',
    ],
    'Swedish League' => [
        'AIK',
        'Degerfors',
        'Djurgardens',
        'Elfsborg',
        'Goteborg',
        'Hacken',
        'Hammarby',
        'Helsingborg',
        'Kalmar',
        'Malmo',
        'Mjallby',
        'Norrkoping',
        'Sirius',
        'Sundsvall',
        'Varbergs',
        'Varnamo',
    ],
    'Norwegian League' => [
        'Aalesunds',
        'Bodo Glimt',
        'HamKam',
        'Haugesund',
        'Jerv',
        'Kristiansund',
        'Lillestrom',
        'Molde',
        'Odd',
        'Rosenborg',
        'Sandefjord',
        'Sarpsborg',
        'Stromsgodset',
        'Tromso',
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
        'Oulu',
        'SJK',
        'VPS Vaasa',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

# Write all data out to new sorted data structure to copy back into this file

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

# Write all data out as a lisp list

my $lisp_hash = {};
my $out_dir = "c:/mine/lisp/data";

my $iterator = each_array (@summer_leagues, @summer_csv_leagues);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $sorted->{$league};
}

print "\nWriting data to $out_dir/summer-teams.dat...";
my $tt2 = MyTemplate->new (
    filename => "$out_dir/summer-teams.dat",
    template => "template/write_lisp_teams.tt",
    data => $lisp_hash,
);
$tt2->write_file ();

print " Done";

=begin comment
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

=end comment
=cut
