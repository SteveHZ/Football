#!	C:/Strawberry/perl/bin

#	db.pl 24-25/02/18

use strict;
use warnings;

#use DBI;
use Football::DBModel;
use Football::Globals qw( @csv_leagues );

my $query_dispatch = {
	'h' => \&Football::DBModel::get_homes,
	'a' => \&Football::DBModel::get_aways,
};
my $output_dispatch = {
	'h' => \&Football::DBModel::print_homes,
	'a' => \&Football::DBModel::print_aways,
};

my $dbmodel = Football::DBModel->new;
my $dbh = $dbmodel->connect;
	
my $leagues = $dbmodel->build_leagues ($dbh, \@csv_leagues);

while (my ($team, $ha) = get_cmdline ()) {
	last if $team eq 'x';
	die "Usage : (team name) [-h|-a]" unless $ha =~ /[h|a]/;

	my $league = $dbmodel->find_league ($team, $leagues, \@csv_leagues);
	get_results ($dbh, $league, $team, $ha);
}
$dbh->disconnect;

sub get_cmdline {
	print "\nDB > ";
	chomp (my $in = <STDIN>);
	my ($team, $ha) = split (' -', $in);
	return ($team, $ha);
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

=head1
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
=cut