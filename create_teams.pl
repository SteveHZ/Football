#	create_teams.pl 28/03/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

use strict;
use warnings;

use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use MyTemplate;
use Football::Globals qw(@league_names);

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'teams.json';

my $leagues = {
	'Premier League' => [
		'Arsenal',
		'Bournemouth',
		'Chelsea',
		'Crystal Palace',
		'Everton',
		'Leicester',
		'Liverpool',
		'Man City',
		'Man United',
		'Southampton',
		'Tottenham',
		'Watford',
		'West Ham',
		'Burnley',
		'Newcastle',
		'Brighton',
		'Wolves',
		'Aston Villa',
		'Norwich',
		'Sheffield United',
	],
	'Championship' => [
		'Birmingham',
		'Bristol City',
		'Brentford',
		'Derby',
		'Leeds',
		"Nottm Forest",
		'Preston',
		'QPR',
		'Reading',
		'Sheffield Weds',
		'Middlesbrough',
		'Hull',
		'Millwall',
		'Stoke',
		'Swansea',
		'West Brom',
		'Blackburn',
		'Wigan',
		'Cardiff',
		'Fulham',
		'Huddersfield',
		'Luton',
		'Barnsley',
		'Charlton',
	],
	'League One' => [
		'Fleetwood Town',
		'Gillingham',
		'Peterboro',
		'Rochdale',
		'Shrewsbury',
		'Southend',
		'AFC Wimbledon',
		'Bristol Rvs',
		'Oxford',
		'Portsmouth',
		'Doncaster',
		'Blackpool',
		'Burton',
		'Sunderland',
		'Accrington',
		'Coventry',
		'Wycombe',
		'Rotherham',
		'Ipswich',
		'Bolton',
		'Milton Keynes Dons',
		'Lincoln',
		'Bury',
		'Tranmere',
	],
	'League Two' => [
		'Colchester',
		'Crewe',
		'Cambridge',
		'Carlisle',
		'Crawley Town',
		'Exeter',
		'Mansfield',
		'Morecambe',
		'Newport County',
		'Stevenage',
		'Cheltenham',
		'Grimsby',
		'Port Vale',
		'Swindon',
		'Forest Green',
		'Oldham',
		'Northampton',
		'Macclesfield',
		'Plymouth',
		'Walsall',
		'Scunthorpe',
		'Bradford',
		'Salford',
		'Leyton Orient',
	],
	'Conference' => [
		'Dag and Red',
		'Aldershot',
		'Barrow',
		'Boreham Wood',
		'Bromley',
		'Dover Athletic',
		'Eastleigh',
		'Wrexham',
		'Sutton',
		'Solihull',
		'Hartlepool',
		'Fylde',
		'Halifax',
		'Ebbsfleet',
		'Maidenhead',
		'Barnet',
		'Chesterfield',
		'Harrogate',
		'Notts County',
		'Yeovil',
		'Woking',
		'Torquay',
		'Chorley',
		'Stockport',
	],
	'Scots Premier' => [
		'Aberdeen',
		'Celtic',
		'Hamilton',
		'Kilmarnock',
		'Motherwell',
		'Hearts',
		'St Johnstone',
		'Rangers',
		'Hibernian',
		'St Mirren',
		'Livingston',
		'Ross County',
	],
	'Scots Championship' => [
		'Dundee United',
		'Morton',
		'Queen of Sth',
		'Dunfermline',
		'Inverness C',
		'Partick',
		'Ayr',
		'Alloa',
		'Dundee',
		'Arbroath',
	],
	'Scots League One' => [
		'Airdrie Utd',
		'Stranraer',
		'East Fife',
		'Forfar',
		'Raith Rvs',
		'Dumbarton',
		'Montrose',
		'Falkirk',
		'Clyde',
		'Peterhead',
	],
	'Scots League Two' => [
		'Cowdenbeath',
		'Annan Athletic',
		'Elgin',
		'Stirling',
		'Edinburgh City',
		'Albion Rvs',
		'Queens Park',
		'Brechin',
		'Stenhousemuir',
		'Cove Rangers',
	],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

my $out_file = 'new_teams.pl';
print "\nWriting new sorted team list to $out_file...";

my $tt = MyTemplate->new (filename => $out_file);
my $out_fh = $tt->open_file ();
$tt->process('Template/create_new_teams.tt', { leagues => \@league_names, sorted => $sorted }, $out_fh)
    or die $tt->error;
print " Done";

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
