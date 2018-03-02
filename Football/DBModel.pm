package Football::DBModel;

use DBI;
#use Football::Globals qw( @csv_leagues );

use Moo;
use namespace::clean;

sub connect {
	my $db = DBI->connect ("DBI:CSV:", undef, undef, {
		f_dir => "data",
		f_ext => ".csv",
		csv_eol => "\n",
		RaiseError => 1,
	})	or die "Couldn't connect to database : ".DBI->errstr;
	return $db;
}

sub build_leagues {
	my ($self, $dbh, $csv_leagues) = @_;
	my %leagues = ();

	for my $league (@$csv_leagues) {
		print "\nBuilding $league..";
		my $query = "select distinct HomeTeam from $league";
		my $sth = $dbh->prepare ($query)
			or die "Couldn't prepare statement : ".$dbh->errstr;
		$sth->execute;
		
		my @temp = ();
		while (my $row = $sth->fetchrow_hashref) {
			push (@temp, $row->{HomeTeam} );
		}
		$leagues{$league} =  \@temp;
	}
	print "\n";
	return \%leagues;
}

sub find_league {
	my ($self, $team, $leagues, $csv_leagues) = @_;
	for my $league (@$csv_leagues) {
		return $league if grep { $_ eq $team} @{ $leagues->{$league} };
	}
	return 0;
}

#	called by $query_dispatch

sub get_homes {
	my $league = shift;
	return "select Date, AwayTeam, FTHG, FTAG, B365H from $league
			where (HomeTeam = ? and FTHG > FTAG)";
}

sub get_aways {
	my $league = shift;
	return "select Date, HomeTeam, FTAG, FTHG, B365A from $league
			where (AwayTeam = ? and FTAG > FTHG)";
}

#	called by $output_dispatch

sub print_homes {
	my $row = shift;

	print "\n$row->{Date} ";
	printf "%-20s", $row->{AwayTeam};
	print "$row->{FTHG}-$row->{FTAG}  $row->{B365H}";
}

sub print_aways {
	my $row = shift;

	print "\n$row->{Date} ";
	printf "%-20s", $row->{HomeTeam};
	print "$row->{FTAG}-$row->{FTHG}  $row->{B365A}";
}

1;
