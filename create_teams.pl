#	create_teams.pl 28/03/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, use Euro::Rename
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);

use Football::Globals qw(@league_names);

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'teams.json';

my $leagues = {
    'Premier League' => [
        'Arsenal',
        'Aston Villa',
        'Bournemouth',
        'Brighton',
        'Burnley',
        'Chelsea',
        'Crystal Palace',
        'Everton',
        'Leicester',
        'Liverpool',
        'Man City',
        'Man United',
        'Newcastle',
        'Norwich',
        'Sheffield United',
        'Southampton',
        'Tottenham',
        'Watford',
        'West Ham',
        'Wolves',
    ],
    'Championship' => [
        'Barnsley',
        'Birmingham',
        'Blackburn',
        'Brentford',
        'Bristol City',
        'Cardiff',
        'Charlton',
        'Derby',
        'Fulham',
        'Huddersfield',
        'Hull',
        'Leeds',
        'Luton',
        'Middlesbrough',
        'Millwall',
        'Nottm Forest',
        'Preston',
        'QPR',
        'Reading',
        'Sheffield Weds',
        'Stoke',
        'Swansea',
        'West Brom',
        'Wigan',
    ],
    'League One' => [
        'AFC Wimbledon',
        'Accrington',
        'Blackpool',
        'Bolton',
        'Bristol Rvs',
        'Burton',
        'Coventry',
        'Doncaster',
        'Fleetwood Town',
        'Gillingham',
        'Ipswich',
        'Lincoln',
        'Milton Keynes Dons',
        'Oxford',
        'Peterboro',
        'Portsmouth',
        'Rochdale',
        'Rotherham',
        'Shrewsbury',
        'Southend',
        'Sunderland',
        'Tranmere',
        'Wycombe',
    ],
    'League Two' => [
        'Bradford',
        'Cambridge',
        'Carlisle',
        'Cheltenham',
        'Colchester',
        'Crawley Town',
        'Crewe',
        'Exeter',
        'Forest Green',
        'Grimsby',
        'Leyton Orient',
        'Macclesfield',
        'Mansfield',
        'Morecambe',
        'Newport County',
        'Northampton',
        'Oldham',
        'Plymouth',
        'Port Vale',
        'Salford',
        'Scunthorpe',
        'Stevenage',
        'Swindon',
        'Walsall',
    ],
    'Conference' => [
        'Aldershot',
        'Barnet',
        'Barrow',
        'Boreham Wood',
        'Bromley',
        'Chesterfield',
        'Chorley',
        'Dag and Red',
        'Dover Athletic',
        'Eastleigh',
        'Ebbsfleet',
        'Fylde',
        'Halifax',
        'Harrogate',
        'Hartlepool',
        'Maidenhead',
        'Notts County',
        'Solihull',
        'Stockport',
        'Sutton',
        'Torquay',
        'Woking',
        'Wrexham',
        'Yeovil',
    ],
    'Scots Premier' => [
        'Aberdeen',
        'Celtic',
        'Hamilton',
        'Hearts',
        'Hibernian',
        'Kilmarnock',
        'Livingston',
        'Motherwell',
        'Rangers',
        'Ross County',
        'St Johnstone',
        'St Mirren',
    ],
    'Scots Championship' => [
        'Alloa',
        'Arbroath',
        'Ayr',
        'Dundee',
        'Dundee United',
        'Dunfermline',
        'Inverness C',
        'Morton',
        'Partick',
        'Queen of Sth',
    ],
    'Scots League One' => [
        'Airdrie Utd',
        'Clyde',
        'Dumbarton',
        'East Fife',
        'Falkirk',
        'Forfar',
        'Montrose',
        'Peterhead',
        'Raith Rvs',
        'Stranraer',
    ],
    'Scots League Two' => [
        'Albion Rvs',
        'Annan Athletic',
        'Brechin',
        'Cove Rangers',
        'Cowdenbeath',
        'Edinburgh City',
        'Elgin',
        'Queens Park',
        'Stenhousemuir',
        'Stirling',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

my $out_file = 'data/teams/uk_teams.pl';
my $tt = MyTemplate->new (
    filename => $out_file,
    template => 'Template/create_new_teams.tt',
    data => {
        leagues => \@league_names,
        sorted => $sorted,
    },
);
print "\nWriting new sorted team list to $out_file...";
$tt->write_file ();

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
