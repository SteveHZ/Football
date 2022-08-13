#	create_teams.pl 28/03/16

#	This file is for team names to be used within predict.pl
#	To edit names from Football Data CSV files, create an anonymous sub in Football::Fetch_Amend
#	To edit names from BBC fixtures files use Football::Fixtures_Globals

#	To edit team names through whole system, need to amend here,
#	in Football::Fixtures_Globals, and in Football::Fetch_Amend
#	Also need to check Football::Fetch_Amend before the start of each season for promotion/relegation

#	DEPRECATED 10/08/22 : To edit names from Football Data CSV files, use Euro::Rename

# 	IMPORTANT !!!
# 	See Football::Favourites::Model re start of next season !!!

#	All leagues done 16/06/22
#	Ran script and pasted in sorted teams 18/06/22, Lisp file not created so need to run again at start of season
# 	Checked new team names and re-ran full script 13/08/22

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
        'Leeds',
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
        'Birmingham',
        'Blackburn',
        'Blackpool',
        'Bristol City',
        'Burnley',
        'Cardiff',
        'Coventry',
        'Huddersfield',
        'Hull',
        'Luton',
        'Middlesbrough',
        'Millwall',
        'Norwich',
        'Preston',
        'QPR',
        'Reading',
        'Rotherham',
        'Sheff Utd',
        'Stoke',
        'Sunderland',
        'Swansea',
        'Watford',
        'West Brom',
        'Wigan',
    ],
    'League One' => [
        'Accrington',
        'Barnsley',
        'Bolton',
        'Bristol Rvs',
        'Burton',
        'Cambridge',
        'Charlton',
        'Cheltenham',
        'Derby',
        'Exeter',
        'Fleetwood Town',
        'Forest Green',
        'Ipswich',
        'Lincoln',
        'MK Dons',
        'Morecambe',
        'Oxford',
        'Peterboro',
        'Plymouth',
        'Port Vale',
        'Portsmouth',
        'Sheff Wed',
        'Shrewsbury',
        'Wycombe',
    ],
    'League Two' => [
        'Barrow',
        'Bradford',
        'Carlisle',
        'Colchester',
        'Crawley Town',
        'Crewe',
        'Doncaster',
        'Gillingham',
        'Grimsby',
        'Harrogate',
        'Hartlepool',
        'Leyton Orient',
        'Mansfield',
        'Newport County',
        'Northampton',
        'Rochdale',
        'Salford',
        'Stevenage',
        'Stockport',
        'Sutton',
        'Swindon',
        'Tranmere',
        'Walsall',
        'Wimbledon',
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
        'Gateshead',
        'Halifax',
        'Maidenhead',
        'Maidstone',
        'Notts County',
        'Oldham',
        'Scunthorpe',
        'Solihull',
        'Southend',
        'Torquay',
        'Wealdstone',
        'Woking',
        'Wrexham',
        'Yeovil',
        'York City',
    ],
    'Scots Premier' => [
        'Aberdeen',
        'Celtic',
        'Dundee United',
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
        'Arbroath',
        'Ayr',
        'Cove Rangers',
        'Dundee',
        'Hamilton',
        'Inverness',
        'Morton',
        'Partick',
        'Queens Park',
        'Raith Rvs',
    ],
    'Scots League One' => [
        'Airdrie Utd',
        'Alloa',
        'Clyde',
        'Dunfermline',
        'Edinburgh',
        'Falkirk',
        'Kelty Hearts',
        'Montrose',
        'Peterhead',
        'Queen of Sth',
    ],
    'Scots League Two' => [
        'Albion Rvs',
        'Annan Athletic',
        'Bonnyrigg Rose',
        'Dumbarton',
        'East Fife',
        'Elgin',
        'Forfar',
        'Stenhousemuir',
        'Stirling',
        'Stranraer',
    ],
};

print "\nWriting $json_file...";
my $sorted = sort_HoA ($leagues);
write_json ($json_file, $sorted);
print " Done";

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
print "\nWriting new sorted team list to $out_file...";
$tt->write_file ();

print " Done";

# Write all data out as a lisp list

my $lisp_hash = {};
my $out_dir = 'C:/Mine/lisp/data';

my $iterator = each_array (@league_names, @csv_leagues);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $sorted->{$league};
}

print "\nWriting data to $out_dir/uk-teams.dat...";
my $tt2 = MyTemplate->new (
    filename => "$out_dir/uk-teams.dat",
    template => 'Template/write_lisp_teams.tt',
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
