#	create_teams.pl 28/03/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, create an anonymous sub in Football::Fetch_Amend
#	To edit names from BBC fixtures files use Football::Fixtures_Globals, possibly also Football::Fixtures_Model

#	To edit team names through whole system, need to amend here,
#	in Football::Fixtures_Globals, and in Football::Fetch_Amend
#	Also need to check Football::Fetch_Amend before the start of each season for promotion/relegation

#	Euro::Rename WAS used to edit Football Data CSV files, DO NOT USE - DEPRECATED 10/08/22

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
        'Burnley',
        'Chelsea',
        'Crystal Palace',
        'Everton',
        'Fulham',
        'Liverpool',
        'Luton',
        'Man City',
        'Man Utd',
        'Newcastle',
        'Notts Forest',
        'Sheff Utd',
        'Tottenham',
        'West Ham',
        'Wolves',
    ],
    'Championship' => [
        'Birmingham',
        'Blackburn',
        'Bristol City',
        'Cardiff',
        'Coventry',
        'Huddersfield',
        'Hull',
        'Ipswich',
        'Leeds',
        'Leicester',
        'Middlesboro',
        'Millwall',
        'Norwich',
        'Plymouth',
        'Preston',
        'QPR',
        'Rotherham',
        'Sheff Wed',
        'Southampton',
        'Stoke',
        'Sunderland',
        'Swansea',
        'Watford',
        'West Brom',
    ],
    'League One' => [
        'Barnsley',
        'Blackpool',
        'Bolton',
        'Bristol Rvs',
        'Burton',
        'Cambridge',
        'Carlisle',
        'Charlton',
        'Cheltenham',
        'Derby',
        'Exeter',
        'Fleetwood',
        'Leyton Orient',
        'Lincoln',
        'Northampton',
        'Oxford',
        'Peterboro',
        'Port Vale',
        'Portsmouth',
        'Reading',
        'Shrewsbury',
        'Stevenage',
        'Wigan',
        'Wycombe',
    ],
    'League Two' => [
        'Accrington',
        'Barrow',
        'Bradford',
        'Colchester',
        'Crawley',
        'Crewe',
        'Doncaster',
        'Forest Green',
        'Gillingham',
        'Grimsby',
        'Harrogate',
        'MK Dons',
        'Mansfield',
        'Morecambe',
        'Newport',
        'Notts County',
        'Salford',
        'Stockport',
        'Sutton',
        'Swindon',
        'Tranmere',
        'Walsall',
        'Wimbledon',
        'Wrexham',
    ],
    'Conference' => [
        'Aldershot',
        'Altrincham',
        'Barnet',
        'Boreham Wood',
        'Bromley',
        'Chesterfield',
        'Dag and Red',
        'Dorking',
        'Eastleigh',
        'Ebbsfleet',
        'Fylde',
        'Gateshead',
        'Halifax',
        'Hartlepool',
        'Kidderminster',
        'Maidenhead',
        'Oldham',
        'Oxford City',
        'Rochdale',
        'Solihull',
        'Southend',
        'Wealdstone',
        'Woking',
        'York',
    ],
    'Scots Premier' => [
        'Aberdeen',
        'Celtic',
        'Dundee',
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
        'Airdrie',
        'Arbroath',
        'Ayr',
        'Dundee Utd',
        'Dunfermline',
        'Inverness',
        'Morton',
        'Partick',
        'Queens Park',
        'Raith Rvs',
    ],
    'Scots League One' => [
        'Alloa',
        'Annan Athletic',
        'Cove Rangers',
        'Edinburgh',
        'Falkirk',
        'Hamilton',
        'Kelty Hearts',
        'Montrose',
        'Queen of Sth',
        'Stirling',
    ],
    'Scots League Two' => [
        'Bonnyrigg Rose',
        'Clyde',
        'Dumbarton',
        'East Fife',
        'Elgin',
        'Forfar',
        'Peterhead',
        'Spartans',
        'Stenhousemuir',
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
