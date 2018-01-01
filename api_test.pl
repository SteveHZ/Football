#!	C:/Strawberry/perl/bin

#	03/07/16

use strict;
use warnings;

use Football::APIv1;
#use Data::Dumper;

my $path = 'C:/Mine/perl/Football/data/';
my $premdata = $path.'E0.csv';
#my $json_file = $path.'season.json';

main ();

sub main {
	my $api = Football::APIv1->new ();
	
	print "\nHOMES :";
	view_team ($api->get_homes ($premdata, "Stoke"));
	<>;
	print "\nAWAYS :";
	view_team ($api->get_aways ($premdata, "Stoke"));
	<>;
	print "\nALL :";
	view_team ($api->get_all ($premdata, "Stoke"));
}

sub view_team {
	my $results = shift;
	
	for my $game (@$results) {
		printf "\n%-9s - %-16s v %-16s",$game->{date}, $game->{home_team}, $game->{away_team};
		print "\t$game->{home_score} - $game->{away_score}";
	}
}