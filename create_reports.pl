#!	C:/Strawberry/perl/bin

# 	create_head2head.pl 09-24/02/16
#	renamed create_reports.pl 05/03/16

use strict;
use warnings;

use Football::Head2Head;
use Football::Reports::Reports;

my $seasons = {
	h2h_seasons => [qw( 2009 2010 2011 2012 2013 2014) ],
	all_seasons => [qw(	1995 1996 1997 1998 1999 2000 2001
						2002 2003 2004 2005 2006 2007 2008
						2009 2010 2011 2012 2013 2014) ],
};

my $teams = [	"Arsenal", "Aston Villa", "Bournemouth", "Chelsea", "Crystal Palace",
				"Everton", "Leicester", "Liverpool", "Man City", "Man United",
				"Newcastle", "Norwich", "Southampton", "Stoke", "Sunderland",
				"Swansea", "Tottenham", "Watford", "West Brom", "West Ham",
];

main ();

sub main {
	my $head2head = Football::Head2Head->new ($seasons, $teams);

	my $reports = Football::Reports::Reports->new ($seasons);
	$reports->run ($seasons);
}

#use Football::LeaguePlaces; 
#	my $league_places = Football::LeaguePlaces->new ($seasons);
