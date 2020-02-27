# backtest.pl 16/02/20

use MyHeader;
use Football::Globals qw(@league_names);
use Football::BackTest::Model;
use DBI;

my $model = Football::BackTest::Model->new ();
my $dbh = $model->connect (dir => 'C:/Mine/perl/Football/data/backtest');
my $totals = {};

for my $query (get_query ()->@*) {
    my $stake = {};
    my $wins = {};
    $totals->{stake} = 0;
    $totals->{wins} = 0;

    say "\n\n$query->{query} :";
    for my $league (@league_names) {
        $stake->{$league} = 0;
        $wins->{$league} = 0;

        $model->do_query (
            league => $league,
            data => { stake => $stake, wins => $wins, totals => $totals },
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
    printf "\nTotal Stake = %4d \tTotal Wins = %8.2f \tRatio = %0.2f",
        $totals->{stake}, $totals->{wins}, $totals->{wins} / $totals->{stake};
}

say "";
$model->disconnect ();

sub get_query {
    return [
        {
            query => "season_home_expect > season_away_expect + 2",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{result} eq 'H' && $row->{b365h}) {
                    $data->{wins}->{$league} += $row->{b365h};
                    $data->{totals}->{wins} += $row->{b365h};
                }
            },
        },
        {
            query => "season_home_expect + 2 < season_away_expect",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{result} eq 'A' && $row->{b365a}) {
                    $data->{wins}->{$league} += $row->{b365a};
                    $data->{totals}->{wins} += $row->{b365a};
                }
            },
        },
        {
            query => "recent_home_expect > recent_away_expect + 2",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{result} eq 'H' && $row->{b365h}) {
                    $data->{wins}->{$league} += $row->{b365h};
                    $data->{totals}->{wins} += $row->{b365h};
                }
            },
        },
    {
            query => "recent_home_expect + 2 < recent_away_expect",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{result} eq 'A' && $row->{b365a}) {
                    $data->{wins}->{$league} += $row->{b365a};
                    $data->{totals}->{wins} += $row->{b365a};
                }
            },
        },
    {
            query => "season_draw <= 2 and season_draw < season_home_win and season_draw < season_away_win",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{result} eq 'D' && $row->{b365d}) {
                    $data->{wins}->{$league} += $row->{b365d};
                    $data->{totals}->{wins} += $row->{b365d};
                }
            },
        },
        {
            query => "recent_draw <= 2 and recent_draw < recent_home_win and recent_draw < recent_away_win",
            callback => sub {
                my ($row, $league, $data) = @_;
                if ($row->{result} eq 'D' && $row->{b365d}) {
                    $data->{wins}->{$league} += $row->{b365d};
                    $data->{totals}->{wins} += $row->{b365d};
                }
            },
        },
##        {
#            query => "draw <= 2.3 and draw < home_win and draw < away_win",
#            callback => sub {
#                my ($row, $league, $data) = @_;
#                if ($row->{b365d}) {
#                    $data->{wins}->{$league} += $row->{b365d} if $row->{result} eq 'D';
#                }
#            },
#        },

    ];
}
#   say " $row->{date} $row->{home_team} $row->{away_team} $row->{home_score}-$row->{away_score}
#         $row->{home_win} $row->{draw} $row->{away_win}";
