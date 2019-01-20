package Football::Football_Data_API;

#	moved to Football::Football_Data_Model

use DBI;
use List::MoreUtils qw(any pairwise);

use Moo;
use namespace::clean;

#   for DBI
has 'connect' => (is => 'ro', default => 'csv');
has 'keys' => (is => 'ro', default => sub { [ qw(div date hometeam awayteam fthg ftag) ] } );
#   for CSV
has 'my_keys' => (is => 'ro', default => sub { [ qw(Date Home_Team Away_Team Home_Score Away_Score) ] } );
has 'my_cols' => (is => 'ro', default => sub { [ qw(1 2 3 4 5) ] } );

has 'path' => (is => 'ro', default => 'C:/Mine/perl/Football/data');

sub BUILD {
	my $self = shift;

    if ($self->{connect} eq 'dbi') {
        $self->{dbh} = DBI->connect ('DBI:CSV:', undef, undef, {
            f_dir => $self->{path},
            f_ext => '.csv',
            csv_eol => "\n",
            RaiseError => 1,
        })	or die "Couldn't connect to database : ".DBI->errstr;
    }
}

sub do_query {
    my ($self, $stmt) = @_;
    my @rows = ();

    die "No DBI connection !" unless $self->{dbh};
    my $sth = $self->{dbh}->prepare ($stmt)
        or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
    $sth->execute ();
    while (my $row = $sth->fetchrow_hashref) {
        push @rows, {
            map { $_ => $row->{$_} } @{ $self->{keys} }
        };
    }
    return \@rows;
}

sub read_csv {
	my ($self, $file) = @_;
	my @league_games = ();

	open my $fh, '<', $file or die "Can't find $file";
	my $line = <$fh>;	# skip first line
	while ($line = <$fh>) {
		my @data = split ',', $line;
		last if $data [0] eq ''; # don't remove !!!
		next if any {$_ eq ''} ( $data[4], $data[5] );

        push @league_games, {
            pairwise { $a => $data[$b] }
                @{ $self->{my_keys} }, @{ $self->{my_cols} }
        };
	}
	close $fh;
	return \@league_games;
}

#		push ( @league_games, {
#			date => $data [1],
#			home_team => $data [2],
#			away_team => $data [3],
#			home_score => $data [4],
#			away_score => $data [5],
#		});

sub do_query_orig {
    my ($self, $stmt) = @_;

    my $sth = $self->{dbh}->prepare ($stmt)
        or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
    $sth->execute ();
    return $sth;
}

sub DESTROY {
	my $self = shift;
    if ($self->{dbh}) {
       $self->{dbh}->disconnect;
    }
}

=cut

=pod

=head1 NAME

Football_Data_API.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
