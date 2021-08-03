
#	create_teams.pl 28/03/16

#	This file is for team names to be used within predict.pl
##	To edit names from Football Data CSV files, use Euro::Rename (INCORRECT / OUTDATED ???)
#	To edit names from Football Data CSV files, create an anonymous sub in Football::Fetch_Amend
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

#	To edit team names through whole system, need to amend here,
#	in Football::Fixtures_Globals, and in Football::Fetch_Amend
#	Also need to check Football::Fetch_Amend before the start of each season for promotion/relegation

# 	Scots leagues done 15/06/21
#	English leagues done 03/07/21 - script not run yet

use strict;
use warnings;

use MyTemplate;
use MyJSON qw(write_json);
use MyLib qw(sort_HoA);
use Football::Globals qw(@league_names @csv_leagues);
use List::MoreUtils qw(each_array);

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'teams.json';

my $leagues = {
    'Premier League' => [
        'Arsenal',
        'Aston Villa',
        'Brighton',
        'Burnley',
        'Chelsea',
        'Crystal Palace',
        'Everton',
        'Leeds',
        'Leicester',
        'Liverpool',
        'Man City',
        'Man Utd',
        'Newcastle',
        'Southampton',
        'Tottenham',
        'West Ham',
        'Wolves',
        'Norwich',
        'Watford',
        'Brentford',
    ],
    'Championship' => [
        'Barnsley',
        'Birmingham',
        'Blackburn',
        'Bournemouth',
        'Bristol City',
        'Cardiff',
        'Coventry',
        'Derby',
        'Huddersfield',
        'Luton',
        'Middlesbrough',
        'Millwall',
        'Notts Forest',
        'Preston',
        'QPR',
        'Reading',
        'Stoke',
        'Swansea',
        'Sheff Utd',
        'West Brom',
        'Fulham',
        'Hull',
        'Peterboro',
        'Blackpool',
    ],
    'League One' => [
        'AFC Wimbledon',
        'Accrington',
        'Burton',
        'Charlton',
        'Crewe',
        'Doncaster',
        'Fleetwood Town',
        'Gillingham',
        'Ipswich',
        'Lincoln',
        'MK Dons',
        'Oxford',
        'Plymouth',
        'Portsmouth',
        'Shrewsbury',
        'Sunderland',
        'Wigan',
        'Wycombe',
        'Sheff Wed',
        'Rotherham',
        'Cheltenham',
        'Cambridge',
        'Bolton',
        'Morecambe',
    ],
    'League Two' => [
        'Barrow',
        'Bradford',
        'Carlisle',
        'Colchester',
        'Crawley Town',
        'Exeter',
        'Forest Green',
        'Harrogate',
        'Leyton Orient',
        'Mansfield',
        'Newport County',
        'Oldham',
        'Port Vale',
        'Salford',
        'Scunthorpe',
        'Stevenage',
        'Tranmere',
        'Walsall',
        'Bristol Rvs',
        'Swindon',
        'Rochdale',
        'Northampton',
        'Sutton',
        'Hartlepool',
    ],
    'Conference' => [
        'Aldershot',
        'Altrincham',
        'Barnet',
        'Boreham Wood',
        'Bromley',
        'Chesterfield',
        'Dag and Red',
        'Dover Athletic',
        'Eastleigh',
        'Halifax',
        'Kings Lynn',
        'Maidenhead',
        'Notts County',
        'Solihull',
        'Stockport',
        'Torquay',
        'Wealdstone',
        'Weymouth',
        'Woking',
        'Wrexham',
        'Yeovil',
        'Grimsby',
        'Southend',
    ],
    'Scots Premier' => [
        'Aberdeen',
        'Celtic',
        'Dundee United',
        'Hibernian',
        'Livingston',
        'Motherwell',
        'Rangers',
        'Ross County',
        'St Johnstone',
        'St Mirren',
        'Dundee',
        'Hearts',
    ],
    'Scots Championship' => [
        'Arbroath',
        'Ayr',
        'Dunfermline',
        'Inverness C',
        'Queen of Sth',
        'Raith Rvs',
        'Hamilton',
        'Kilmarnock',
        'Partick',
        'Morton',
    ],
    'Scots League One' => [
        'Airdrie Utd',
        'Clyde',
        'Cove Rangers',
        'Dumbarton',
        'East Fife',
        'Falkirk',
        'Montrose',
        'Peterhead',
        'Alloa',
        'Queens Park',
    ],
    'Scots League Two' => [
        'Albion Rvs',
        'Annan Athletic',
        'Cowdenbeath',
        'Edinburgh City',
        'Elgin',
        'Stenhousemuir',
        'Stirling',
        'Stranraer',
        'Forfar',
		'Kelty Hearts',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

# Write all data out to new sorted data structure to copy back into this file

my $out_file = 'data/teams/uk_teams.pl';
my $tt = MyTemplate->new (
    template => 'Template/create_new_teams.tt',
    filename => $out_file,
    data => {
        leagues => \@league_names,
        sorted => $sorted,
    },
);
print "\nWriting new sorted team list to $out_file...";
$tt->write_file ();

print " Done";

# Write all data out as a lisp list

my $lisp_hash = {};
my $out_dir = "c:/mine/lisp/data";

my $iterator = each_array (@league_names, @csv_leagues);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $sorted->{$league};
}

print "\nWriting data to $out_dir/uk-teams.dat...";
my $tt2 = MyTemplate->new (
    template => "template/write_lisp_teams.tt",
    filename => "$out_dir/uk-teams.dat",
    data => $lisp_hash,
);
$tt2->write_file ();

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
