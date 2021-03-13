#   correct_historical.pl 12/03/21
#   script written to correct errors in historical favourites files in 2019
#   caused by column key changes in Football Data files

use strict;
use warnings;

use Football::Favourites::Data_Model;
use Football::Globals qw(@league_names);

my $data_model = Football::Favourites::Data_Model->new ();
my $year = 2019;

for my $league (@league_names) {
    my $in_path = "C:/Mine/perl/Football/data/historical";
    my $out_path = "C:/Mine/perl/Football/data/favourites/$league";

    print "\nCorrecting $league $year...";
    my $amended = $data_model->update_current ("$in_path/$league/$year.csv", $year);
    $data_model->write_current ("$out_path/$year.csv", $amended);
}
