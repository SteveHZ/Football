#!	C:/Strawberry/perl/bin

#	create_teams.pl 28/03/16
#	2018 done 23/06

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
		"Tottenham",
		"Watford",
		"West Ham",
		"Burnley",
		"Newcastle",
		"Brighton",
		"Huddersfield",
		"Wolves",
		"Cardiff",
		"Fulham",
	],
	"Championship" => [
		"Aston Villa",
		"Norwich",
		"Birmingham",
		"Bristol City",
		"Brentford",
		"Derby",
		"Ipswich",
		"Leeds",
		"Nott'm Forest",
		"Preston",
		"QPR",
		"Reading",
		"Sheffield Weds",
		"Middlesbrough",
		"Hull",
		"Sheffield United",
		"Bolton",
		"Millwall",
		"Stoke",
		"Swansea",
		"West Brom",
		"Blackburn",
		"Wigan",
		"Rotherham",
	],
	"League One" => [
		"Charlton",
		"Bradford",
		"Fleetwood Town",
		"Gillingham",
		"Peterboro",
		"Rochdale",
		"Scunthorpe",
		"Shrewsbury",
		"Southend",
		"Walsall",
		"AFC Wimbledon",
		"Bristol Rvs",
		"Oxford",
		"Plymouth",
		"Portsmouth",
		"Doncaster",
		"Blackpool",
		"Barnsley",
		"Burton",
		"Sunderland",
		"Accrington",
		"Luton",
		"Coventry",
		"Wycombe",
	],
	"League Two" => [
		"Colchester",
		"Crewe",
		"Cambridge",
		"Carlisle",
		"Crawley Town",
		"Exeter",
		"Mansfield",
		"Morecambe",
		"Newport County",
		"Notts County",
		"Stevenage",
		"Yeovil",
		"Cheltenham",
		"Grimsby",
		"Port Vale",
		"Swindon",
		"Lincoln",
		"Forest Green",
		"Milton Keynes Dons",
		"Bury",
		"Oldham",
		"Northampton",
		"Macclesfield",
		"Tranmere",
	],
	"Conference" => [
		"Dag and Red",
		"Aldershot",
		"Barrow",
		"Boreham Wood",
		"Bromley",
		"Dover Athletic",
		"Eastleigh",
		"Gateshead",
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
		"Barnet",
		"Chesterfield",
		"Salford",
		"Havant & Waterlooville",
		"Harrogate Town",
		"Braintree Town",
	],
	"Scots Premier" => [
		"Aberdeen",
		"Celtic",
		"Dundee",
		"Hamilton",
		"Kilmarnock",
		"Motherwell",
		"Hearts",
		"St Johnstone",
		"Rangers",
		"Hibernian",
		"St Mirren",
		"Livingston",
	],
	"Scots Championship" => [
		"Dundee United",
		"Falkirk",
		"Morton",
		"Queen of Sth",
		"Dunfermline",
		"Inverness C",
		"Partick",
		"Ross County",
		"Ayr",
		"Alloa",
	],
	"Scots League One" => [
		"Airdrie Utd",
		"Stranraer",
		"East Fife",
		"Arbroath",
		"Forfar",
		"Raith Rvs",
		"Brechin",
		"Dumbarton",
		"Montrose",
		"Stenhousemuir",
	],
	"Scots League Two" => [
		"Cowdenbeath",
		"Annan Athletic",
		"Berwick",
		"Clyde",
		"Elgin",
		"Stirling",
		"Edinburgh City",
		"Peterhead",
		"Albion Rvs",
		"Queens Park",
	],
};

my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "\nDone";

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