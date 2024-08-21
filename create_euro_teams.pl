#	create_euro_teams.pl 26/06/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, create an anonymous sub in Football::Fetch_Amend
#	To edit names from BBC fixtures files use Football::Fixtures_Globals, possibly also Football::Fixtures_Model

#	To edit team names through whole system, need to amend here,
#	in Football::Fixtures_Globals, and in Football::Fetch_Amend
#	Also need to check Football::Fetch_Amend before the start of each season for promotion/relegation

#	Euro::Rename WAS previously used to edit Football Data CSV files, DO NOT USE - DEPRECATED 10/08/22

#	Updated 16/07/24

use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use Football::Globals qw(@euro_lgs @euro_csv_lgs);
use List::MoreUtils qw(each_array);

my $path = 'C:/Mine/perl/Football/data/Euro';
my $json_file = "$path/teams.json";

my $leagues = {
    'German League' => [
        'Augsburg',
        'Bayern Munich',
        'Bochum',
        'Dortmund',
        'Frankfurt',
        'Freiburg',
        'Heidenheim',
        'Hoffenheim',
        'Holsten Kiel',
        'Leverkusen',
        'Mainz',
        'Mgladbach',
        'RB Leipzig',
        'St Pauli',
        'Stuttgart',
        'Union Berlin',
        'Werder Bremen',
        'Wolfsburg',
    ],
    'Spanish League' => [
        'Alaves',
        'Ath Bilbao',
        'Ath Madrid',
        'Barcelona',
        'Betis',
        'Celta',
        'Espanyol',
        'Getafe',
        'Girona',
        'Las Palmas',
        'Leganes',
        'Mallorca',
        'Osasuna',
        'Real Madrid',
        'Sevilla',
        'Sociedad',
        'Valencia',
        'Valladolid',
        'Vallecano',
        'Villarreal',
    ],
    'Italian League' => [
        'Atalanta',
        'Bologna',
        'Cagliari',
        'Como',
        'Empoli',
        'Fiorentina',
        'Frosinone',
        'Genoa',
        'Inter',
        'Juventus',
        'Lazio',
        'Lecce',
        'Milan',
        'Monza',
        'Napoli',
        'Roma',
        'Torino',
        'Udinese',
        'Venezia',
        'Verona',
    ],
    'French League' => [
        'Angers',
        'Auxerre',
        'Brest',
        'Le Havre',
        'Lens',
        'Lille',
        'Lyon',
        'Marseille',
        'Monaco',
        'Montpellier',
        'Nantes',
        'Nice',
        'PSG',
        'Reims',
        'Rennes',
        'St Etienne',
        'Strasbourg',
        'Toulouse',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

# Write all data out to new sorted data structure to copy back into this file

my $out_file = 'data/teams/euro_teams.pl';
my $tt = MyTemplate->new (
    filename => $out_file,
    template => 'Template/create_new_teams.tt',
    data => {
        leagues => \@euro_lgs,
        sorted => $sorted,
    },
);
print "\nWriting new sorted team list to $out_file...";
$tt->write_file ();

print " Done";

# Write all data out as a lisp list

my $lisp_hash = {};
my $out_dir = 'C:/Mine/lisp/data';

my $iterator = each_array (@euro_lgs, @euro_csv_lgs);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $sorted->{$league};
}

print "\nWriting data to $out_dir/euro-teams.dat...";
my $tt2 = MyTemplate->new (
    filename => "$out_dir/euro-teams.dat",
    template => 'Template/write_lisp_teams.tt',
    data => $lisp_hash,
);
$tt2->write_file ();

print " Done";

=head
'Welsh League' => [
    'Aberystwyth',
	'Bala Town',
	'Barry Town',
	'Caernarfon Town',
	'Cardiff MU',
    'Cefn Druids',
    'Connahs Quay',
    'Newtown',
    'Penybont',
    'TNS',
	'Flint',
	'Haverfordwest',
],
'N Irish League' => [
    'Ballymena',
    'Carrick Rangers',
    'Cliftonville',
    'Coleraine',
    'Crusaders',
    'Dungannon',
    'Glenavon',
    'Glentoran',
  	'Larne',
    'Linfield',
    'Warrenpoint',
	'Portadown',
],

'German 2 League' => [
	'Bochum',
	'Bielefeld',
	'Darmstadt',
	'Ingolstadt',
	'Dresden',
	'Holstein Kiel',
	'Nurnberg',
	'Fortuna Dusseldorf',
	'St Pauli',
	'Regensburg',
	'Greuther Furth',
	'Union Berlin',
	'Duisburg',
	'Sandhausen',
	'Kaiserslautern',
	'Braunschweig',
	'Heidenheim',
	'Erzgebirge Aue',
],
'Belgian League' => [
	'Antwerp',
	'Anderlecht',
	'Charleroi',
	'Kortrijk',
	'Eupen',
	'Waregem',
	'Genk',
	'Waasland-Beveren',
	'Lokeren',
	'Club Brugge',
	'Mechelen',
	'Standard',
	'Oostende',
	'Mouscron',
	'St Truiden',
	'Gent',
],

'Australian League' => [
	'Adelaide United',
	'Brisbane Roar',
	'Central Coast Mariners',
	'Melbourne City',
	'Melbourne Victory',
	'Newcastle Jets',
	'Perth Glory',
	'Sydney FC',
	'Wellington Phoenix',
	'Western Sydney Wdrs',
	'Western United',
],
'Dutch League' => [
    'AZ Alkmaar',
    'Ajax',
    'Cambuur',
    'Emmen',
    'Excelsior',
    'Feyenoord',
    'Fortuna',
    'Go Ahead Eagles',
    'Groningen',
    'Heerenveen',
    'NEC',
    'PSV',
    'RKC',
    'Sparta',
    'Twente',
    'Utrecht',
    'Vitesse',
    'Volendam',
],

## 20/01/22
## Went wrong with Greuther Furth	Mainz (05)
## (1899) Hoffenheim	Borussia Dortmund
##
## => Greuther Furth	14:30	Mainz99 Hoffenheim	Borussia Dortmund

=cut
