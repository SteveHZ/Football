package Football::BenchTest::FileList;

use List::MoreUtils qw(each_arrayref);
use File::Find;

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
#       create array of hashrefs for each league, containing another arrayref of hashrefs
#       only one hashref per arrayref for this sub, but get_historical will have a hashref
#       for each season, so done this way to be compatible in Season.pm
        push @list, {
            $league => [{
                tag => $league,
                name => "$self->{path}/$csv_league.csv",
            }]
        };
    }
    return \@list;
}

sub get_historical {
    my $self = shift;
    my @list = ();

    for my $league ( $self->{leagues}->@* ) {
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

=pod

=head1 NAME

Football/BenchTest/FileList.pm

=head1 SYNOPSIS

used by backtest.pl

=head1 DESCRIPTION

Creates data structure of file lists as required

data structure from get_current
{
    'Premier League' => [
        {
            'tag' => 'Premier League',
            'name' => 'C:/Mine/perl/Football/data/E0.csv'
        }
    ]
};

data_structure from get_historical

{
    'Premier League' => [
        {
            'name' => 'C:/Mine/perl/Football/data/historical/Premier League/2015.csv',
            'tag' => 'Premier League 2015'
        },
        {
            'name' => 'C:/Mine/perl/Football/data/historical/Premier League/2016.csv',
            'tag' => 'Premier League 2016'
        },
        {
            'name' => 'C:/Mine/perl/Football/data/historical/Premier League/2017.csv',
            'tag' => 'Premier League 2017'
        }
    ]
};

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
