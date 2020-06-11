#   write_lisp_teams.pl 01/05/20

use strict;
use warnings;
use List::MoreUtils qw(each_array);

use MyJSON qw(read_json);
use Football::Globals qw(@league_names @csv_leagues);
use MyTemplate;

my $lisp_hash = {};
my $out_dir = "c:/mine/lisp/data";
my $teams = read_json "c:/mine/perl/football/data/teams.json";

my $iterator = each_array (@league_names, @csv_leagues);
while (my ($league, $csv) = $iterator->()) {
    $lisp_hash->{$csv} = $teams->{$league};
}

print "\nWriting data to $out_dir/teams.dat";
my $tt = MyTemplate->new (
    filename => "$out_dir/teams.dat",
    template => "template/write_lisp_teams.tt",
    data => $lisp_hash,
);
$tt->write_file ();
