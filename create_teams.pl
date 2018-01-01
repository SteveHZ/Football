#!	C:/Strawberry/perl/bin

#	create_teams.pl 28/03/16

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'teams.json';

my $leagues = {
	"Premier League" => [
		"Arsenal",
		"Bournemouth",
		"Chelsea",
		"Crystal Palace",
		"Everton",
		"Leicester",
		"Liverpool",
		"Man City",
		"Man United",
		"Southampton",
		"Stoke",
		"Swansea",
		"Tottenham",
		"Watford",
		"West Brom",
		"West Ham",
		"Burnley",
		"Newcastle",
		"Brighton",
		"Huddersfield",
	],
	"Championship" => [
		"Aston Villa",
		"Norwich",
		"Birmingham",
		"Bristol City",
		"Brentford",
		"Cardiff",
		"Derby",
		"Fulham",
		"Ipswich",
		"Leeds",
		"Nott'm Forest",
		"Preston",
		"QPR",
		"Reading",
		"Sheffield Weds",
		"Wolves",
		"Barnsley",
		"Burton",
		"Middlesbrough",
		"Hull",
		"Sunderland",
		"Sheffield United",
		"Bolton",
		"Millwall",
	],
	"League One" => [
		"Charlton",
		"Milton Keynes Dons",
		"Bradford",
		"Bury",
		"Fleetwood Town",
		"Gillingham",
		"Oldham",
		"Peterboro",
		"Rochdale",
		"Scunthorpe",
		"Shrewsbury",
		"Southend",
		"Walsall",
		"AFC Wimbledon",
		"Bristol Rvs",
		"Northampton",
		"Oxford",
		"Blackburn",
		"Wigan",
		"Rotherham",
		"Plymouth",
		"Portsmouth",
		"Doncaster",
		"Blackpool",
	],
	"League Two" => [
		"Colchester",
		"Crewe",
		"Accrington",
		"Barnet",
		"Cambridge",
		"Carlisle",
		"Crawley Town",
		"Exeter",
		"Luton",
		"Mansfield",
		"Morecambe",
		"Newport County",
		"Notts County",
		"Stevenage",
		"Wycombe",
		"Yeovil",
		"Cheltenham",
		"Grimsby",
		"Port Vale",
		"Swindon",
		"Coventry",
		"Chesterfield",
		"Lincoln",
		"Forest Green",
	],
	"Conference" => [
		"Dag and Red",
		"Aldershot",
		"Barrow",
		"Boreham Wood",
		"Bromley",
		"Chester",
		"Dover Athletic",
		"Eastleigh",
		"Gateshead",
		"Guiseley",
		"Macclesfield",
		"Torquay",
		"Tranmere",
		"Woking",
		"Wrexham",
		"Maidstone",
		"Sutton",
		"Solihull",
		"Hartlepool",
		"Leyton Orient",
		"Fylde",
		"Halifax",
		"Ebbsfleet",
		"Maidenhead",
	],
	"Scots Premier" => [
		"Aberdeen",
		"Celtic",
		"Dundee",
		"Hamilton",
		"Kilmarnock",
		"Motherwell",
		"Hearts",
		"Partick",
		"Ross County",
		"St Johnstone",
		"Rangers",
		"Hibernian",
	],
	"Scots Championship" => [
		"Dundee United",
		"Dumbarton",
		"Falkirk",
		"Morton",
		"Queen of Sth",
		"St Mirren",
		"Dunfermline",
		"Brechin",
		"Inverness C",
		"Livingston",
	],
	"Scots League One" => [
		"Alloa",
		"Airdrie Utd",
		"Albion Rvs",
		"Stranraer",
		"East Fife",
		"Queens Park",
		"Arbroath",
		"Forfar",
		"Ayr",
		"Raith Rvs",
	],
	"Scots League Two" => [
		"Cowdenbeath",
		"Annan Athletic",
		"Berwick",
		"Clyde",
		"Elgin",
		"Montrose",
		"Stirling",
		"Edinburgh City",
		"Peterhead",
		"Stenhousemuir",
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);

=pod

=head1 NAME

perl create_teams.pl

=head1 SYNOPSIS

perl create_teams.pl

=head1 DESCRIPTION

Create Football/teams.json file

=head1 AUTHOR

Steve Hope 2016

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut