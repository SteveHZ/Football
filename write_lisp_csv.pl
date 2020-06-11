#   write_lisp_csv.pl 26/04/20

use strict;
use warnings;
use List::MoreUtils qw(each_array);

use MyTemplate;
use Football::Football_Data_Model;
use Football::Globals qw(@league_names @csv_leagues);

my $data = {};
my $out_dir = "c:/mine/lisp/data";
my $data_model = Football::Football_Data_Model->new ({
    my_keys => [ qw(date home_team away_team home_score away_score result) ],
});

my $iterator = each_array (@league_names, @csv_leagues);
while (my ($league, $csv) = $iterator->()) {
    $data->{$league} = $data_model->read_csv ("c:/mine/perl/football/data/$csv.csv");

    my $tt = MyTemplate->new (
        filename => "$out_dir/$csv.csv",
        template => "template/write_lisp_csv.tt",
        data => $data->{$league},
    );
    print "\nWriting $league to $out_dir/$csv.csv";
    $tt->write_file ();
}
