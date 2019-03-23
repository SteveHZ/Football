package Football::BenchTest::FileList;

use List::MoreUtils qw(each_arrayref);
use File::Find;
use Data::Dumper;

use Moo;
use namespace::clean;

has 'path' => (is => 'ro', default => 'C:/Mine/perl/Football/data');
has 'leagues' => (is => 'ro', required => 1);
has 'csv_leagues' => (is => 'ro', required => 1);

sub get_current {
    my $self = shift;
    my @list = ();
    my $iterator = each_arrayref ($self->{leagues}, $self->{csv_leagues});
    while (my ($league, $csv_league) = $iterator->()) {
#       create array of hashrefs made up of an arrayref of hashrefs
        push @list, {
            $league => [ {
                tag => $league,
                name => "$self->{path}/$csv_league.csv",
            } ]
        };
    }
    return \@list;
}

sub get_historical {
    my $self = shift;
    my @list = ();

    for my $league (@{ $self->{leagues} }) {
        my @files = ();
        my $league_path = "$self->{path}/$league";
        find ( sub {
            push @files, $_ if $_ =~ /\.csv$/
        }, $league_path );

#       map to sorted arrayref of hashrefs
        push @list, {
            $league => [
                map { {
                    tag  => historical_tag ($league, $_),   #   Premier League 2018
                    name => "$league_path/$_",              #   $path/Premier League/2018.csv
                } }
                sort { $a cmp $b } @files
        ] };
    }
    return \@list;
}

sub historical_tag {
    my ($league, $file) = @_;
    return "$league ".remove_ext ($file);
}

sub remove_ext {
    return ( split '\.', $_[0] )[0];
}

1;
