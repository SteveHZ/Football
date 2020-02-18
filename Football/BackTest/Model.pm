package Football::BackTest::Model;

use MyHeader;
use DBI;
use Function::Parameters qw(method);

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

method do_query (:$league, :$data, :$query, :$callback) {
    my $sql = "SELECT * FROM '$league' WHERE $query";
    my $sth = $self->{dbh}->prepare ($sql);
    $sth->execute ();

    while (my $row = $sth->fetchrow_hashref) {
        $data->{stake}->{$league} ++;
        $callback->($row, $league, $data);
    }
}

1;
