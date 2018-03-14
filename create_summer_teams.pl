#!	C:/Strawberry/perl/bin

#	create_euro_teams.pl 26/06/16
#	Irish and USA done 12/03/18

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

my $path = 'C:/Mine/perl/Football/data/Euro/';
my $json_file = $path.'teams.json';

my $leagues = {
	"Irish League" => [
		"Dundalk",
		"St Patricks",
		"Limerick",
		"Bohemians",
		"Cork City",
		"Shamrock Rovers",
		"Bray",
		"Sligo Rovers",
		"Derry City",
		"Waterford",
	],
	"Swedish League" => [
		"IFK Goteborg",
		"IFK Norrkoping",
		"GIF Sundsvall",
		"AIK",
		"Orebro SK",
		"Kalmar FF",
		"Djurgardens IF",
		"Ostersunds FK",
		"Malmo FF",
		"Hammarby IF",
		"BK Hacken",
		"IF Elfsborg",
		"IK Sirius",
		"Dalkurd FF",
		"IF Brommapojkarna",
		"Trellborgs FF",
	],
	"Norwegian League" => [
		"Kristiansund BK",
		"Rosenborg",
		"Tromso",
		"Stromsgodset",
		"Stabak",
		"Sarpsborg",
		"Lillestrom",
		"Valerenga",
		"Molde",
		"Odd",
		"Brann",
		"FK Haugesund",
		"Sandefjord",
		"Bodo Glimt",
		"IK Start",
		"Ranheim",
	],
	"USA League" => [
		"Portland Timbers",
		"Minnesota",
		"Chicago Fire",
		"Columbus Crew",
		"Los Angeles Galaxy",
		"Los Angeles FC",
		"FC Dallas",
		"Toronto FC",
		"Real Salt Lake",
		"Colorado Rapids",
		"New England Revolution",
		"Sporting Kansas City",
		"DC United",
		"Houston Dynamo",
		"Seattle Sounders",
		"Montreal Impact",
		"San Jose Earthquakes",
		"Orlando City",
		"New York City",
		"New York Red Bulls",
		"Atlanta United",
		"Vancouver Whitecaps",
		"Philadelphia Union",
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);

=head
	"Welsh League" => [
		"Bala Town",
		"Bangor City",
		"Prestatyn Town",
		"Cefn Druids",
		"Llandudno FC",
		"Barry Town",
		"Newtown",
		"The New Saints",
		"Connah's Quay Nomads",
		"Cardiff MU",
		"Carmarthen Town",
		"Aberystwyth Town",
	],
	"Northern Irish League" => [
		"Ballymena United",
		"Ballinamallard United",
		"Cliftonville",
		"Dungannon Swifts",
		"Linfield",
		"Warrenpoint Town",
		"Crusaders",
		"Glentoran",
		"Ards",
		"Coleraine",
		"Carrick Rangers",
		"Glenavon",
	],
	"Highland League" => [
		"Buckie Thistle",
		"Cove Rangers",
		"Deveronvale",
		"Formartine United",
		"Forres Mechanics",
		"Fraserburgh",
		"Keith",
		"Lossiemouth",
		"Rothes",
		"Clachnacuddin",
		"Huntly",
		"Turriff United",
		"Inverurie Loco Works",
		"Nairn County",
		"Wick Academy",
		"Fort William",
		"Brora Rangers",
		"Strathspey Thistle",
	],
=cut