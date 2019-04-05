#	create_euro_teams.pl 26/06/16

#	Team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

my $path = 'C:/Mine/perl/Football/data/Euro/';
my $json_file = $path.'teams.json';

my $leagues = {
	'Welsh' => [
		'Bala Town',
		'Cefn Druids',
		'Llandudno',
		'Barry Town',
		'Newtown',
		'TNS',
		'Connahs Quay',
		'Cardiff MU',
		'Carmarthen Town',
		'Aberystwyth',
		'Caernarfon Town',
		'Llanelli',
	],
	'N Irish' => [
		'Ballymena',
		'Cliftonville',
		'Dungannon',
		'Linfield',
		'Warrenpoint',
		'Crusaders',
		'Glentoran',
		'Ards',
		'Coleraine',
		'Glenavon',
		'Institute',
		'Newry City',
	],
	'German' => [
		'Bayern Munich',
		'Leverkusen',
		'Augsburg',
		'Hertha',
		'Stuttgart',
		'Hoffenheim',
		'Werder Bremen',
		'Mainz',
		'Hannover',
		'Schalke 04',
		'RB Leipzig',
		'Wolfsburg',
		'Dortmund',
		'Freiburg',
		'Ein Frankfurt',
		"M'gladbach",
		'Fortuna Dusseldorf',
		'Nurnberg',
	],
	'Italian' => [
		'Juventus',
		'Cagliari',
		'Napoli',
		'Atalanta',
		'Roma',
		'Bologna',
		'Torino',
		'Milan',
		'Inter',
		'Fiorentina',
		'Lazio',
		'Spal',
		'Sampdoria',
		'Sassuolo',
		'Genoa',
		'Udinese',
		'Chievo',
		'Frosinone',
		'Empoli',
		'Parma',
	],
	'Spanish' => [
		'Leganes',
		'Alaves',
		'Valencia',
		'Celta',
		'Sociedad',
		'Girona',
		'Ath Madrid',
		'Sevilla',
		'Espanol',
		'Ath Bilbao',
		'Getafe',
		'Barcelona',
		'Betis',
		'Real Madrid',
		'Levante',
		'Villarreal',
		'Eibar',
		'Valladolid',
		'Huesca',
		'Vallecano',
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "\nDone";

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
