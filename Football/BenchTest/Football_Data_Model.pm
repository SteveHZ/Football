package Football::BenchTest::Football_Data_Model;

use Moo;
use namespace::clean;

extends 'Football::Football_Data_Model';
has '+connect' => (default => 'dbi');

sub get_result {
    my ($self, $league, $home, $away) = @_;
    my @bind = ($home, $away);

    my $sth = $self->{dbh}->prepare ("SELECT FTR FROM $league WHERE HOMETEAM = ? AND AWAYTEAM = ?")
        or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
    $sth->execute (@bind);
    my $row = $self->{dbh}->selectrow_hashref($sth);
    die "Database error : $home v $away" unless $row;
	return $row->{FTR};
}

sub get_over_under_result {
    my ($self, $league, $home, $away) = @_;
    my @bind = ($home,$away);

    my $sth = $self->{dbh}->prepare ("SELECT FTHG, FTAG, FTR FROM $league WHERE HOMETEAM = ? AND AWAYTEAM = ?")
        or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
    $sth->execute (@bind);
    my $row = $self->{dbh}->selectrow_hashref($sth);
    die "Database error : $home v $away" unless $row;

    my $goals = $row->{FTHG} + $row->{FTAG};
	return {
        result => $row->{FTR},
        goals  => $goals,
    };
}

1;
