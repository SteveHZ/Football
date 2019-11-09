#   over_under_count.pl 03/11/19
#   Calculate percentage of Over 2.5 games for each league

use strict;
use warnings;
use List::MoreUtils qw(each_arrayref);

use Football::Globals qw(@league_names @csv_leagues);
use Football::Football_Data_Model;

my $path = "C:/Mine/perl/Football/data";
my $data_model = Football::Football_Data_Model->new ();
do_count (\@league_names, \@csv_leagues, $path);

my @euro_lgs = qw(NIrish Welsh);
my @euro_csv = qw(NI WL);
$path = "C:/Mine/perl/Football/data/Euro";
do_count (\@euro_lgs, \@euro_csv, $path);

sub do_count {
    my ($league_names, $csv_leagues, $path) = @_;
    my $iterator = each_arrayref ($league_names, $csv_leagues);

    while (my ($league, $csv) = $iterator->()) {
        my $games = $data_model->read_csv ("$path/$csv.csv");
        my ($over, $num_games) = (0,0);
        for my $game (@$games) {
            $over ++ if ($game->{home_score} + $game->{away_score} > 2);
            $num_games ++;
        }
        print "\n$league : $over from $num_games = ".sprintf ("%0.2f %%", $over/$num_games * 100);
    }
}
