#!	C:/Strawberry/perl/bin

#	12/07/17

use strict;
use warnings;
use Data::Dumper;

use Football::APIv2;
use Football::Globals qw(@csv_leagues);

main ();

sub main {
	my $db = Football::APIv2->new ();
	print Dumper $db;<>;
	
	for my $league (@csv_leagues) {
		my $q = "select Date, HomeTeam, AwayTeam, FTHG, FTAG from $league";
		my $result = $db->query ($q);
		print Dumper $result;<>;
	}
}