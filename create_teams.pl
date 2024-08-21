#	create_teams.pl 28/03/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, create an anonymous sub in Football::Fetch_Amend
#	To edit names from BBC fixtures files use Football::Fixtures_Globals, possibly also Football::Fixtures_Model

#	To edit team names through whole system, need to amend here,
#	in Football::Fixtures_Globals, and in Football::Fetch_Amend
#	Also need to check Football::Fetch_Amend before the start of each season for promotion/relegation

#	Euro::Rename WAS used to edit Football Data CSV files, DO NOT USE - DEPRECATED 10/08/22

#	Updated all leagues 15/07/24

use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use Football::Globals qw(@league_names @csv_leagues);
use List::MoreUtils qw(each_array);

my $path = 'C:/Mine/perl/Football/data';
my $json_file = "$path/teams.json";

my $leagues = {
    'Premier League' => [
        'Arsenal',
        'Aston Villa',
        'Bournemouth',
        'Brentford',
        'Brighton',
        'Chelsea',
        'Crystal Palace',
        'Everton',
        'Fulham',
        'Ipswich',
        'Leicester',
        'Liverpool',
        'Man City',
        'Man Utd',
        'Newcastle',
        'Notts Forest',
        'Southampton',
        'Tottenham',
        'West Ham',
        'Wolves',
    ],
    'Championship' => [
        'Blackburn',
        'Bristol City',
        'Burnley',
        'Cardiff',
        'Coventry',
        'Derby',
        'Hull',
        'Leeds',
        'Luton',
        'Middlesboro',
        'Millwall',
        'Norwich',
        'Oxford',
        'Plymouth',
        'Portsmouth',
        'Preston',
        'QPR',
        'Sheff Utd',
        'Sheff Wed',
        'Stoke',
        'Sunderland',
        'Swansea',
        'Watford',
        'West Brom',
    ],
    'League One' => [
        'Barnsley',
        'Birmingham',
        'Blackpool',
        'Bolton',
        'Bristol Rvs',
        'Burton',
        'Cambridge',
        'Charlton',
        'Crawley',
        'Exeter',
        'Huddersfield',
        'Leyton Orient',
        'Lincoln',
        'Mansfield',
        'Northampton',
        'Peterboro',
        'Reading',
        'Rotherham',
        'Shrewsbury',
        'Stevenage',
        'Stockport',
        'Wigan',
        'Wrexham',
        'Wycombe',
    ],
    'League Two' => [
        'Accrington',
        'Barrow',
        'Bradford',
        'Bromley',
        'Carlisle',
        'Cheltenham',
        'Chesterfield',
        'Colchester',
        'Crewe',
        'Doncaster',
        'Fleetwood',
        'Gillingham',
        'Grimsby',
        'Harrogate',
        'MK Dons',
        'Morecambe',
        'Newport',
        'Notts County',
        'Port Vale',
        'Salford',
        'Swindon',
        'Tranmere',
        'Walsall',
        'Wimbledon',
    ],
    'Conference' => [
        'Aldershot',
        'Altrincham',
        'Barnet',
        'Boston',
        'Braintree',
        'Dag and Red',
        'Eastleigh',
        'Ebbsfleet',
        'Forest Green',
        'Fylde',
        'Gateshead',
        'Halifax',
        'Hartlepool',
        'Maidenhead',
        'Oldham',
        'Rochdale',
        'Solihull',
        'Southend',
        'Sutton',
        'Tamworth',
        'Wealdstone',
        'Woking',
        'Yeovil',
        'York',
    ],
    'Scots Premier' => [
        'Aberdeen',
        'Celtic',
        'Dundee',
        'Dundee Utd',
        'Hearts',
        'Hibernian',
        'Kilmarnock',
        'Motherwell',
        'Rangers',
        'Ross County',
        'St Johnstone',
        'St Mirren',
    ],
    'Scots Championship' => [
        'Airdrie',
        'Ayr',
        'Dunfermline',
        'Falkirk',
        'Hamilton',
        'Livingston',
        'Morton',
        'Partick',
        'Queens Park',
        'Raith Rvs',
    ],
    'Scots League One' => [
        'Alloa',
        'Annan Athletic',
        'Arbroath',
        'Cove Rangers',
        'Dumbarton',
        'Inverness',
        'Kelty Hearts',
        'Montrose',
        'Queen of Sth',
        'Stenhousemuir',
    ],
    'Scots League Two' => [
        'Bonnyrigg Rose',
        'Clyde',
        'East Fife',
        'Edinburgh',
        'Elgin',
        'Forfar',
        'Peterhead',
        'Spartans',
        'Stirling',
        'Stranraer',
    ],
};

print "\nWriting $json_file... ";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print "Done";

# Write all data out to new sorted data structure to copy back into this file

my $out_file = 'data/teams/uk_teams.pl';
my $tt = MyTemplate->new (
    filename => $out_file,
    template => 'Template/create_new_teams.tt',
    data => {
        leagues => \@league_names,
        sorted => $sorted,
    },
);
print "\nWriting new sorted team list to $out_file... ";
$tt->write_file ();

print "Done";

# Write all data out as a lisp list

my $lisp_hash = {};
my $out_dir = 'C:/Mine/lisp/data';

my $iterator = each_array (@league_names, @csv_leagues);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $sorted->{$league};
}

print "\nWriting data to $out_dir/uk-teams.dat... ";
my $tt2 = MyTemplate->new (
    filename => "$out_dir/uk-teams.dat",
    template => 'Template/write_lisp_teams.tt',
    data => $lisp_hash,
);
$tt2->write_file ();

print "Done";

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
