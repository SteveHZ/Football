package Football::DBModel;

use DBI;

use Moo;
use namespace::clean;

has 'dbh' => ( is => 'ro' );
has 'data' => (is => 'ro' );

sub BUILD {
	my $self = shift;
	$self->{dbh} = DBI->connect ("DBI:CSV:", undef, undef, {
		f_dir => $self->{data}->{path},
		f_ext => ".csv",
		csv_eol => "\n",
		RaiseError => 1,
	})	or die "Couldn't connect to database : ".DBI->errstr;
}

sub DESTROY {
	my $self = shift;
	$self->{dbh}->disconnect;
}

sub build_leagues {
	my ($self, $csv_leagues) = @_;
	my %leagues = ();

	for my $league (@$csv_leagues) {
		print "\nBuilding $league..";
		my $query = "select distinct HomeTeam from $league";
		my $sth = $self->{dbh}->prepare ($query)
			or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
		$sth->execute;
		
		my @temp = ();
		while (my $row = $sth->fetchrow_hashref) {
			push (@temp, $row->{HomeTeam} );
		}
		$leagues{$league} =  \@temp;
	}
	return \%leagues;
}

sub find_league {
	my ($self, $team, $leagues, $csv_leagues) = @_;
	for my $league (@$csv_leagues) {
		return $league if grep { $_ eq $team} @{ $leagues->{$league} };
	}
	return 0;
}

sub query {
	my ($self, $query) = @_;
	my @result = ();
	
	my $sth = $self->{dbh}->prepare ($query)
		or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
	$sth->execute;
	while (my $row = $sth->fetchrow_hashref) {
		push @result, $row;
	}
	return \@result;
}

# 	SQL functions called by dispatch tables

sub get_homes {
	my ($self, $league) = @_;
	return "select Date, AwayTeam, FTHG, FTAG, $self->{data}->{column}H from $league
			where (HomeTeam = ? and FTHG > FTAG)";
}

sub get_aways {
	my ($self, $league) = @_;
	return "select Date, HomeTeam, FTAG, FTHG, $self->{data}->{column}A from $league
			where (AwayTeam = ? and FTAG > FTHG)";
}

=pod

=head1 NAME

DBModel.pm

=head1 SYNOPSIS

Used by db.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
