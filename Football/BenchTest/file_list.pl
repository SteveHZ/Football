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

#my $files = get_current ();
#my $files = get_historical ();
#for my $league (@league_names) {
#    print Dumper $files->{$league};
#    <STDIN>;
#}

#my $path = 'C:/Mine/perl/Football';
#my $files = make_file_list (path => "$path/data", name => 'Zappa');
#print Dumper $files;

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
=head
my $files = get_current ();
#my $files = get_historical ();
for my $league (@league_names) {
    print Dumper $files->{$league};
    <STDIN>;
}
=cut
#print Dumper $files;

#    next unless -d $path/$league;
#    chdir $path.$league;
#     readdir /grep ?

#    print Dumper $path.$league;
#    print Dumper [@files];
#    <STDIN>;
#}
#}

#         grep {
#            $_ =~ /\.csv/
#        } readdir $path.$league;

=head
sub make_file_list {
    my $args = {@_};
    opendir (my $DIR, $args->{path}) or die "Can't open directory $args->{dir}: $!";
    my @files = readdir ($DIR);
    close $DIR;
    return [ grep { $_ =~ /\.csv$/ } @files ];
}

#get current {
#
#    my $path = 'C:/Mine/perl/Football/data';
#}
=cut
=head
return [
    map { {
        'league_idx' => $_,
        'league_name' => $leagues{$_},
    } }
    sort { $a <=> $b } keys %leagues
];
=cut
=head
my @t1 = sort {$b cmp $a}@files;
print Dumper [@t1];
my $t2=  [map {{
#$_=>'zap'
        tag => $league,
        file => "$str/$_",
}} @t1];
print Dumper $t2;
=cut
#$list->{$league} = [
#    map {{
#        tag => $_,
#        filec => $_,
#    }} @t1
#}
#;

#print Dumper [@t1];
