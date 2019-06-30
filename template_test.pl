use strict;
use warnings;

use Template;
use Summer::Summer_Data_Model;

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

my $data_model = Summer::Summer_Data_Model->new ();
my $out_file_tt = "c:/mine/perl/football/data/summer/template_test.csv";
$data_model->write_csv_tt ($out_file_tt, \@data);

print "\n";
use Data::Dumper;
print Dumper get_all_teams (\@data);

sub uniq {
    return { map { $_->{home_team} => 1 } @{ $_[0] } }
}

sub get_all_teams {
    return [ keys %{ uniq $_[0] } ]
}
