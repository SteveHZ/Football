package Football::BackTest::Model;

use MyHeader;
use Football::Globals qw(@league_names @csv_leagues);

use DBI;
use Function::Parameters;

use Moo;
use namespace::clean;

has 'dbh' => (is => 'ro');

sub connect {
    my $self = shift;
    my $args = { dir => 'C:/Mine/perl/Football/data', @_ };

    $self->{dbh} = DBI->connect ('DBI:CSV:', undef, undef, {
        f_dir => $args->{dir},
        f_ext => '.csv',
        csv_eol => "\n",
        RaiseError => 1,
    })	or die "Couldn't connect to database : ".DBI->errstr;
    return $self->{dbh};
}

sub disconnect {
    my $self = shift;
    return $self->{dbh}->disconnect;
}

fun do_query ($self, :$league, :$data, :$query, :$callback) {
    my $sql = "SELECT * FROM '$league' WHERE $query";
    my $sth = $self->{dbh}->prepare ($sql);
    $sth->execute ();
    while (my $row = $sth->fetchrow_hashref) {
        $callback->($row, $league, $data);
    }
}

=head
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
#        "Home_Win < Away_Win AND Away_Win >= 4",
#        "Home_Win < Away_Win AND Away_Win >= 5",
#        "Home_Win < Away_Win AND Away_Win >= 8",
        "gxa > gxh + 1",
        "gxa > gxh + 1.5",
#        "GXA > GXH + 2",
    ];
}
=cut

1;
