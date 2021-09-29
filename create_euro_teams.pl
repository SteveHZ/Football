#	create_euro_teams.pl 26/06/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals


use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use Football::Globals qw(@euro_lgs @euro_csv_lgs);
use List::MoreUtils qw(each_array);

my $path = 'C:/Mine/perl/Football/data/Euro/';
my $json_file = $path.'teams.json';

my $leagues = {
#	'Welsh' => [
#       'Aberystwyth',
#		'Bala Town',
#		'Barry Town',
#		'Caernarfon Town',
#		'Cardiff MU',
#       'Cefn Druids',
#       'Connahs Quay',
#       'Newtown',
#       'Penybont',
#       'TNS',
#		'Flint',
#		'Haverfordwest',
#    ],
#    'N Irish' => [
#       'Ballymena',
#       'Carrick Rangers',
#       'Cliftonville',
#       'Coleraine',
#       'Crusaders',
#       'Dungannon',
#       'Glenavon',
#       'Glentoran',
#    	'Larne',
#       'Linfield',
#       'Warrenpoint',
#		'Portadown',
#    ],
    'German' => [
        'Augsburg',
        'Bayern Munich',
		'Bielefeld',
		'Bochum',
        'Dortmund',
        'Ein Frankfurt',
        'FC Koln',
		'Freiburg',
		'Greuther Furth',
        'Hertha',
        'Hoffenheim',
        'Leverkusen',
        'Mainz',
        'Mgladbach',
        'RB Leipzig',
		'Stuttgart',
        'Union Berlin',
        'Wolfsburg',
    ],
    'Spanish' => [
        'Alaves',
        'Ath Bilbao',
        'Ath Madrid',
        'Barcelona',
        'Betis',
        'Celta',
		'Cadiz',
		'Elche',
        'Espanol',
        'Getafe',
        'Granada',
        'Levante',
        'Mallorca',
        'Osasuna',
        'Real Madrid',
        'Sevilla',
        'Sociedad',
		'Valencia',
		'Vallecano',
		'Villarreal',
    ],
    'Italian' => [
        'Atalanta',
        'Bologna',
        'Cagliari',
		'Empoli',
        'Fiorentina',
        'Genoa',
        'Inter',
        'Juventus',
        'Lazio',
        'Milan',
        'Napoli',
        'Roma',
		'Salernitana',
        'Sampdoria',
        'Sassuolo',
		'Spezia',
        'Torino',
        'Udinese',
		'Verona',
		'Venezia',
    ],
#	'Australian' => [
#		'Adelaide United',
#		'Brisbane Roar',
#		'Central Coast Mariners',
#		'Melbourne City',
#		'Melbourne Victory',
#		'Newcastle Jets',
#		'Perth Glory',
#		'Sydney FC',
#		'Wellington Phoenix',
#		'Western Sydney Wdrs',
#		'Western United',
#	],
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
my $out_dir = "c:/mine/lisp/data";

my $iterator = each_array (@euro_lgs, @euro_csv_lgs);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $sorted->{$league};
}

print "\nWriting data to $out_dir/euro-teams.dat...";
my $tt2 = MyTemplate->new (
    filename => "$out_dir/euro-teams.dat",
    template => "template/write_lisp_teams.tt",
    data => $lisp_hash,
);
$tt2->write_file ();

print " Done";

=head
'German 2' => [
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
'Belgian 1' => [
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
=cut
