#!	C:/Strawberry/perl/bin

#	csvdb_test.pl 18/06/17

use strict;
use warnings;

use DBI;
use Football::Globals qw( @csv_leagues);

main ();

sub main  {
	my $dbh = DBI->connect ("DBI:CSV:", undef, undef, {
		f_dir => "data",
		f_ext => ".csv",
		csv_eol => "\n",
		RaiseError => 1,
	})	or die "Couldn't connect to database : ".DBI->errstr;

	for my $league (@csv_leagues) {
		my $query = "select Date, HomeTeam, AwayTeam, FTHG, FTAG from $league";
		my $sth = $dbh->prepare ($query)
			or die "Couldn't prepare statement : ".$dbh->errstr;
		$sth->execute;

		while (my $row = $sth->fetchrow_hashref) {
			print "\n$row->{Date} ";
			print "$row->{HomeTeam} v $row->{AwayTeam} ";
			print "$row->{FTHG} - $row->{FTAG}";
		}
		<>;
	}
	
	$dbh->disconnect;
}