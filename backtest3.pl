# backtest3.pl 09/02/20

use MyHeader;
use Football::Globals qw(@league_names @csv_leagues);
use DBI;

my $dbh = DBI->connect ('DBI:CSV:', undef, undef, {
    f_dir => 'C:/Mine/perl/Football/data/backtest',
    f_ext => '.csv',
    csv_eol => "\n",
    RaiseError => 1,
})	or die "Couldn't connect to database : ".DBI->errstr;

for my $query (get_query ()->@*) {
    say "\n\n$query :";
    my $stake = {};
    my $wins = {};

    for my $league (@league_names) {
        $stake->{$league} = 0;
        $wins->{$league} = 0;

        my $sql = "SELECT * FROM '$league' WHERE $query";
        my $sth = $dbh->prepare ($sql);
        $sth->execute ();
        while (my $row = $sth->fetchrow_hashref) {
            $stake->{$league} ++;
            if ($row->{b365a}) {
                $wins->{$league} += $row->{b365a} if $row->{result} eq 'A';
            }
#        say " $row->{date} $row->{home_team} $row->{away_team} $row->{home_score}-$row->{away_score} $row->{home_win} $row->{draw} $row->{away_win}";
        }
    }
    for my $league (@league_names) {
        printf "\nLeague = %-20s Stake = %4d \tWins = %8.2f \tRatio = %0.2f",
            $league, $stake->{$league}, $wins->{$league}, $wins->{$league} / $stake->{$league};
    }
}

say "";
$dbh->disconnect;

sub get_query {
    return [
        "gxa > gxh + 1",
        "gxa > gxh + 1.5",
    ];
}
