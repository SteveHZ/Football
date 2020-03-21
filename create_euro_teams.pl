#	create_euro_teams.pl 26/06/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals


# 12/08/19 Updated promoted/relegated teams for all leagues
# but NOT checked against Football Data

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use MyTemplate;
use Football::Globals qw(@euro_lgs);
use Football::TeamsList;

my $path = 'C:/Mine/perl/Football/data/Euro/';
my $json_file = $path.'teams.json';

my $leagues = {
	'Welsh' => [
        'Aberystwyth',
        'Airbus',
        'Bala Town',
        'Barry Town',
        'Caernarfon Town',
        'Cardiff MU',
        'Carmarthen Town',
        'Cefn Druids',
        'Connahs Quay',
        'Newtown',
        'Penybont',
        'TNS',
    ],
    'N Irish' => [
        'Ballymena',
        'Carrick Rangers',
        'Cliftonville',
        'Coleraine',
        'Crusaders',
        'Dungannon',
        'Glenavon',
        'Glentoran',
        'Institute',
        'Larne',
        'Linfield',
        'Warrenpoint',
    ],
    'German' => [
        'Augsburg',
        'Bayern Munich',
        'Dortmund',
        'Ein Frankfurt',
        'FC Koln',
        'Fortuna Dusseldorf',
        'Freiburg',
        'Hertha',
        'Hoffenheim',
        'Leverkusen',
        'Mainz',
        'Mgladbach',
        'Paderborn',
        'RB Leipzig',
        'Schalke 04',
        'Union Berlin',
        'Werder Bremen',
        'Wolfsburg',
    ],
    'Spanish' => [
        'Alaves',
        'Ath Bilbao',
        'Ath Madrid',
        'Barcelona',
        'Betis',
        'Celta',
        'Eibar',
        'Espanol',
        'Getafe',
        'Granada',
        'Leganes',
        'Levante',
        'Mallorca',
        'Osasuna',
        'Real Madrid',
        'Sevilla',
        'Sociedad',
        'Valencia',
        'Valladolid',
        'Villarreal',
    ],
    'Italian' => [
        'Atalanta',
        'Bologna',
        'Brescia',
        'Cagliari',
        'Fiorentina',
        'Genoa',
        'Inter',
        'Juventus',
        'Lazio',
        'Lecce',
        'Milan',
        'Napoli',
        'Parma',
        'Roma',
        'Sampdoria',
        'Sassuolo',
        'Spal',
        'Torino',
        'Udinese',
        'Verona',
    ],
	'Australian' => [
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
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

my $out_file = 'data/teams/euro_teams.pl';
print "\nWriting new sorted team list to $out_file...";

my $team_list = Football::TeamsList->new (
	leagues => \@euro_lgs,
	sorted => $sorted,
	filename => $out_file,
);
$team_list->create ();

my $tt = MyTemplate->new (filename => $out_file);
my $out_fh = $tt->open_file ();
$tt->process ('Template/create_new_teams.tt', { leagues => \@euro_lgs, sorted => $sorted }, $out_fh)
    or die $tt->error;
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
