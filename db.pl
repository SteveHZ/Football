#!	C:/Strawberry/perl/bin

#	db.pl 24-25/02/18

use strict;
use warnings;

use DBI;
use Football::Globals qw( @csv_leagues );

my $query_dispatch = {
	'h' => \&get_homes,
	'a' => \&get_aways,
};
my $output_dispatch = {
	'h' => \&print_homes,
	'a' => \&print_aways,
};

my $dbh = DBI->connect ("DBI:CSV:", undef, undef, {
	f_dir => "data",
	f_ext => ".csv",
	csv_eol => "\n",
	RaiseError => 1,
})	or die "Couldn't connect to database : ".DBI->errstr;
	
my $leagues = build_leagues ($dbh, \@csv_leagues);

while (my ($team, $ha) = get_cmdline ()) {
	last if $team eq 'x';
	die "Usage : (team name) [-h|-a]" unless $ha =~ /[h|a]/;

	my $league = find_league ($team, $leagues, \@csv_leagues);
	get_results ($dbh, $league, $team, $ha);
}
$dbh->disconnect;

sub build_leagues {
	my ($dbh, $csv_leagues) = @_;
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

sub get_cmdline {
	print "\nDB > ";
	chomp (my $in = <STDIN>);
	my ($team, $ha) = split (' -', $in);
	return ($team, $ha);
}

sub find_league {
	my ($team, $leagues, $csv_leagues) = @_;
	for my $league (@$csv_leagues) {
		return $league if grep { $_ eq $team} @{ $leagues->{$league} };
	}
	return 0;
}

sub get_results {
	my ($dbh, $league, $team, $ha) = @_;

	my $query = $query_dispatch->{$ha}->($league);
	my $sth = $dbh->prepare ($query)
		or die "Couldn't prepare statement : ".$dbh->errstr;
	$sth->execute ($team);

	while (my $row = $sth->fetchrow_hashref) {
		$output_dispatch->{$ha}->($row);
	}
	print "\n";
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
