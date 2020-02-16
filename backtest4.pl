# backtest4.pl 16/02/20

use MyHeader;
use Football::Globals qw(@league_names @csv_leagues);
use Football::BackTest::Model;
use DBI;

my $model = Football::BackTest::Model->new ();
my $dbh = $model->connect (dir => 'C:/Mine/perl/Football/data/backtest');

for my $query (get_query ()->@*) {
    say "\n\n$query->{query} :";
    my $stake = {};
    my $wins = {};

    for my $league (@league_names) {
        $stake->{$league} = 0;
        $wins->{$league} = 0;

        $model->do_query (
            league => $league,
            data => { stake => $stake, wins => $wins},
            query => $query->{query},
            callback => $query->{callback},
        );
    }
    for my $league (@league_names) {
        printf "\nLeague = %-20s Stake = %4d \tWins = %8.2f \tRatio = %0.2f",
            $league, $stake->{$league}, $wins->{$league}, $wins->{$league} / $stake->{$league};
    }
}

say "";
$model->disconnect ();

sub get_query {
    return [
        {
            query => "gxa > gxh + 1",
            callback => sub {
                my ($row, $league, $data) = @_;
                $data->{stake}->{$league} ++;
                if ($row->{b365a}) {
                    $data->{wins}->{$league} += $row->{b365a} if $row->{result} eq 'A';
                }
            },
        },
        {
            query => "gxa > gxh + 1.5",
            callback => sub {
                my ($row, $league, $data) = @_;
                $data->{stake}->{$league} ++;
                if ($row->{b365a}) {
                    $data->{wins}->{$league} += $row->{b365a} if $row->{result} eq 'A';
                }
            },
        },
    ];
}
