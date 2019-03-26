use strict;
use warnings;

use Football::Globals qw(@league_names @csv_leagues);
use File::Find qw(find);
use List::MoreUtils qw(each_array);
use Data::Dumper;
use Football::BenchTest::FileList;

my $list = Football::BenchTest::FileList->new (
    leagues     => \@league_names,
    csv_leagues => \@csv_leagues,
);

my $files = $list->get_current ();
for my $file (@$files) {
    print Dumper $file;
}
<STDIN>;

my $list2 = Football::BenchTest::FileList->new (
    leagues     => \@league_names,
    csv_leagues => \@csv_leagues,
    path => 'C:/Mine/perl/Football/data/historical'
);

my $files2 = $list2->get_historical ();
for my $league (@$files2) {
    print Dumper $league;
    <STDIN>;
}

=head
sub get_current {
    my $list = {};
    my $path = 'C:/Mine/perl/Football/data';

    my $iterator = each_array (@league_names, @csv_leagues);
    while (my ($league, $csv_league) = $iterator->()) {
        $list->{$league} = [ {
            tag => $league,
            file => "$path/$csv_league.csv",
        } ];
    }
    return $list;
}

sub get_historical {
    my $list = {};
    my $path = 'C:/Mine/perl/Football/data/historical/';

    for my $league (@league_names) {
        my @files = ();
        my $league_path = "$path$league";
        find ( sub {
            push @files, $_ if $_ =~ /\.csv$/
        }, $league_path );

#	map to sorted array of hashrefs
        $list->{$league} = [
            map { {
                tag  => historical_tag ($league, $_),   #   Premier League 2018
                file => "$league_path/$_",              #   $path/Premier League/2018.csv
            } }
            sort { $a cmp $b } @files
        ];
    }
    return $list;
}

sub historical_tag {
    my ($league, $file) = @_;
    return "$league ".remove_ext ($file);
}

sub remove_ext {
    return ( split '\.', $_[0] )[0];
}
=cut
