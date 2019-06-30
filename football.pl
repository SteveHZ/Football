#19/06/19
use MyHeader;
use List::Util qw(reduce);
#use strict;
#use warnings;
#use Data::Dumper;

my @data = (
    {
        date => '15/02/2019',
        home_team => 'Bohemians',
        away_team => 'Finn Harps',
        home_score => 1,
        away_score => 0,
        result => 'H',
        home_odds => '1.61',
        draw_odds => '3.76',
        away_odds => '5.43',
    },
    {
        date => '15/02/2019',
        home_team => 'Derry City',
        away_team => 'UCD',
        home_score => 3,
        away_score => 0,
        result => 'H',
        home_odds => '1.6',
        draw_odds => '3.85',
        away_odds=> '5.25',
    },
    {
        date=> '15/02/2019',
        home_team => 'Dundalk',
        away_team => 'Sligo Rovers',
        home_score => 1,
        away_score => 1,
        result=> 'D',
        home_odds => '1.18',
        draw_odds=> '6.6',
        away_odds => '13.37',
    },
    {
        date => '25/02/2019',
        home_team => 'Bohemians',
        away_team => 'Finn Harps',
        home_score => 1,
        away_score => 0,
        result => 'H',
        home_odds => '1.61',
        draw_odds => '3.76',
        away_odds => '5.43',
    },
    {
        date => '25/02/2019',
        home_team => 'Derry City',
        away_team => 'UCD',
        home_score => 3,
        away_score => 0,
        result => 'H',
        home_odds => '1.6',
        draw_odds => '3.85',
        away_odds=> '5.25',
    },
    {
        date=> '25/02/2019',
        home_team => 'Dundalk',
        away_team => 'Sligo Rovers',
        home_score => 1,
        away_score => 1,
        result=> 'D',
        home_odds => '1.18',
        draw_odds=> '6.6',
        away_odds => '13.37',
    },
);

print "\n";
print Dumper get_all_teams (\@data);

sub get_all_teams ($data) {
    return [ sort keys %{ uniq_aoh ($data) } ];
}

sub uniq_aoh ($data, $field = 'home_team') {
    return { map { $_->{$field} => 1 } @$data };
}

say 'home scores = '.
    reduce { $a + $b }
    map { $_->{home_score} }
    grep { $_->{result} eq 'H'}
    @data;
