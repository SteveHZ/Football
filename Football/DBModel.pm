package Football::DBModel;

use DBI;
use SQL::Abstract;
use MyKeyword qw(TESTING);
TESTING {
	use Data::Dumper;
}

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
	$self->{venue_hash}= {
		'h' => 'HomeTeam',
		'a' => 'AwayTeam',
	};
	$self->{results_hash} = {
		'H' => {
			'W' => 'H',
			'L' => 'A',
			'D' => 'D',
		},
		'A' => {
			'W' => 'A',
			'L' => 'H',
			'D' => 'D',
		},
	};
	$self->{sqla} = SQL::Abstract->new();
}

sub DESTROY {
	my $self = shift;
	$self->{dbh}->disconnect;
}

sub build_leagues {
	my ($self, $csv_leagues) = @_;
	my %leagues = ();
TESTING { print "\nleagues = ".Dumper $csv_leagues;}
	for my $league (@$csv_leagues) {
TESTING { print "\nleague = $league";}
		print "\nBuilding $league..";
		my $query = "select distinct HomeTeam from $league";
		my $sth = $self->{dbh}->prepare ($query)
			or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
TESTING { print "\nsth = ".Dumper $sth;}
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

sub do_cmd_line {
	my ($self, $cmd_line) = @_;
	my ($team, @opts) = split ' -', $cmd_line;
	$_ =~ s/ // for @opts;
	
	return ($team, \@opts);
}

sub get_homeaway {
	my ($self, $options) = @_;
	return @$options [0];
}

sub build_query {
	my ($self, $team, $opts) = @_;
	my @venues = split '', @$opts[0];
	my @options = map { uc $_ } split '', @$opts[1];
	my @query = ();

	for my $venue (@venues) {
		my $temp = {};
		
		my @results = map { $self->{results_hash}->{uc $venue}->{$_} } @options;
		$temp->{ $self->{venue_hash}->{$venue} } = $team; # HomeTeam = ?
		$temp->{FTR} = [ @results ]; # (FTR = ? OR FTR = ?)...
		push @query, $temp;
	}
	my %qhash = (-or => [ @query ]);
	return \%qhash;
}

sub do_query {
	my ($self, $league, $query) = @_;

    my($stmt, @bind) = $self->{sqla}->select($league, '*', $query);
	my $sth = $self->{dbh}->prepare ($stmt)
		or die "Couldn't prepare statement : ".$self->{dbh}->errstr;
	$sth->execute (@bind);
	TESTING {
		print "\nStatement = $stmt\n";
		print "\nBind = ".Dumper @bind;
	}
	return $sth;
}

#=head
#	used by original db.pl
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
#=cut

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
