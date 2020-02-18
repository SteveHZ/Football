# backtest4.pl 16/02/20

use MyHeader;
use Football::Globals qw(@league_names);
use Football::BackTest::Model;
use DBI;

my $model = Football::BackTest::Model->new ();
my $dbh = $model->connect (dir => 'C:/Mine/perl/Football/data/backtest');

for my $query (get_query ()->@*) {
    my $stake = {};
    my $wins = {};

    say "\n\n$query->{query} :";
    for my $league (@league_names) {
        $stake->{$league} = 0;
        $wins->{$league} = 0;

        $model->do_query (
            league => $league,
            data => { stake => $stake, wins => $wins },
            query => $query->{query},
            callback => sub { $query->{callback}->(@_) },
        );
    }
    for my $league (@league_names) {
        if ($stake->{$league}) {
            printf "\nLeague = %-20s Stake = %4d \tWins = %8.2f \tRatio = %0.2f",
                $league, $stake->{$league}, $wins->{$league}, $wins->{$league} / $stake->{$league};
        }
    }
}

say "";
$model->disconnect ();

sub get_query {
    return [
        {
            query => "away_expect > home_expect + 1.5",
            callback => sub {
                my ($row, $league, $data) = @_;
                $data->{stake}->{$league} ++;
                if ($row->{b365a}) {
                    $data->{wins}->{$league} += $row->{b365a} if $row->{result} eq 'A';
                }
            },
        },
        {
            query => "draw < home_win and draw < away_win",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{b365d}) {
                    $data->{wins}->{$league} += $row->{b365d} if $row->{result} eq 'D';
                }
            },
        },
        {
            query => "draw <= 2.3 and draw < home_win and draw < away_win",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{b365d}) {
                    $data->{wins}->{$league} += $row->{b365d} if $row->{result} eq 'D';
                }
            },
        },

    ];
}
#   say " $row->{date} $row->{home_team} $row->{away_team} $row->{home_score}-$row->{away_score}
#         $row->{home_win} $row->{draw} $row->{away_win}";

#        {
#            query => "gxa > gxh + 1.5",
#            callback => sub {
#                my ($row, $league, $data) = @_;
#                $data->{stake}->{$league} ++;
#                if ($row->{b365a}) {
#                    $data->{wins}->{$league} += $row->{b365a} if $row->{result} eq 'A';
#                }
#            },
#        },
#        {
#            query => "gxa > gxh + 2",
#            callback => sub {
#                my ($row, $league, $data) = @_;
#                $data->{stake}->{$league} ++;
#                if ($row->{b365a}) {
#                    $data->{wins}->{$league} += $row->{b365a} if $row->{result} eq 'A';
#                }
#            },
#        },
