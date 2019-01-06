
#   webquerytest.pl 09/12/15
#	euro_scrape.pl 19/07/17

use strict;
use warnings;
use Web::Query;

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

main ();

sub main {
    my $q;
    my $sites = {
		"League One 2015" => "http://www.scoreboard.com/uk/rugby-league/england/league-1-2015/",
#		"Championship 2015" => "http://www.rugby-league.com/kingstone_press_leagues/results",
	};

	for my $key (keys %$sites) {
		print "\n$key : \n\n";
		$q = wq ($sites->{$key}, { indent=>'**  '} );

		if ($q) {
			print $q->text();
			do_write ($key, $q->text);
			print "\n\nCharacter length : ".length ($q->text());
		} else {
			print "Unable to create object";
		}
	}
}

sub do_write {
	my ($key, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Rugby/scraped/$key.txt";

	open my $fh, ">", $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}
