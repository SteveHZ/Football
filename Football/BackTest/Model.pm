package Football::BackTest::Model;

use MyHeader;
use DBI;
#use Function::Parameters qw(method);

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

{
    use Function::Parameters qw(method);
    method do_query (:$league, :$data, :$query, :$callback) {
        my $sql = "SELECT * FROM '$league' WHERE $query";
        my $sth = $self->{dbh}->prepare ($sql);
        $sth->execute ();

        while (my $row = $sth->fetchrow_hashref) {
            $data->{stake}->{$league} ++;
            $data->{totals}->{stake} ++;
            $callback->($row, $league, $data);
        }
    }
}

=pod

=head1 NAME

Football/BackTest/Model.pm

=head1 SYNOPSIS

Model used by backtest.pl

=head1 DESCRIPTION

Model used by backtest.pl

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
