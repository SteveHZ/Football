#   Football_Data_API.t 15/01/19

use strict;
use warnings;
use v5.10;
use MyLib qw(prompt);
use Football::Globals qw(@csv_leagues);
use Data::Dumper;

use Test::More (tests => 1);
use Football::Football_Data_API;

my $file = 'C:/Mine/perl/Football/t/test data/E0.csv';

is (1,1,'ok');
my $data = Football::Football_Data_API->new (
    connect => 'dbi',
#    path => 'C:/Mine/perl/Football/t/test data',
#    keys => [qw(div date hometeam awayteam fthg ftag referee b365h b365a b365d)],
);
#my $results = {};
#for my $league (@csv_leagues) {
#    $results->{$league} = $data->do_query ("SELECT * FROM $league");
#}

#for my $league (@csv_leagues) {
#    print Dumper $results->{$league};
#    <STDIN>;
#}
my $csv = Football::Football_Data_API->new ();
my $games = $csv->read_csv ($file);
print Dumper $games;

while (my $cmd_line = prompt ('Query',':')) {
	last if $cmd_line eq 'x';
	my $results = $data->do_query ($cmd_line);
print Dumper $results;
}
