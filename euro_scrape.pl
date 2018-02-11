#!	C:/Strawberry/perl/bin

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
		"Welsh" 	=>"http://www.oddsportal.com/soccer/wales/premier-league/results/",
#		"Welsh August" 	=>"http://www.bbc.co.uk/sport/football/welsh-premier-league/scores-fixtures/2017-08",
#		"Welsh Sept" 	=> "http://www.bbc.co.uk/sport/football/welsh-premier-league/scores-fixtures/2017-09",
#		"NI August"		=> "http://www.bbc.co.uk/sport/football/irish-premiership/scores-fixtures/2017-08",
#		"NI Sept" 		=> "http://www.bbc.co.uk/sport/football/irish-premiership/scores-fixtures/2017-09",
#		"HL July"		=> "http://www.bbc.co.uk/sport/football/highland-league/scores-fixtures/2017-07",
#		"HL August"		=> "http://www.bbc.co.uk/sport/football/highland-league/scores-fixtures/2017-08",
#		"HL Sept"		=> "http://www.bbc.co.uk/sport/football/highland-league/scores-fixtures/2017-09",
#		"HL Oct"		=> "http://www.bbc.co.uk/sport/football/highland-league/scores-fixtures/2017-10",
#		"Rugby" 		=> "https://en.wikipedia.org/wiki/2014_Championship_1_season_results",
#		"USA March" 	=> "http://www.bbc.co.uk/sport/football/us-major-league/scores-fixtures/2017-03",
#		"USA April"		=> "http://www.bbc.co.uk/sport/football/us-major-league/scores-fixtures/2017-04",
#		"USA May"		=> "http://www.bbc.co.uk/sport/football/us-major-league/scores-fixtures/2017-05",
#		"Norway April" 	=> "http://www.bbc.co.uk/sport/football/norwegian-tippeligaen/scores-fixtures/2017-04",
#		"Norway May" 	=> "http://www.bbc.co.uk/sport/football/norwegian-tippeligaen/scores-fixtures/2017-05",
#		"Sweden April"	=> "http://www.bbc.co.uk/sport/football/swedish-allsvenskan/scores-fixtures/2017-04",
#		"Sweden May"	=> "http://www.bbc.co.uk/sport/football/swedish-allsvenskan/scores-fixtures/2017-05",
#		"Ireland Feb"	=> "http://www.bbc.co.uk/sport/football/league-of-ireland-premier/scores-fixtures/2017-02",
#		"Ireland March"	=> "http://www.bbc.co.uk/sport/football/league-of-ireland-premier/scores-fixtures/2017-03",
#		"Ireland April"	=> "http://www.bbc.co.uk/sport/football/league-of-ireland-premier/scores-fixtures/2017-04",
#		"Ireland May"	=> "http://www.bbc.co.uk/sport/football/league-of-ireland-premier/scores-fixtures/2017-05",
	};

	for my $key (keys %$sites) {
		print "\n$key : ";
		$q = wq ($sites->{$key}, { indent=>'**  '} );
	
		if ($q) {
			do_write ($key, $q->text);
			print "Done - character length : ".length ($q->text());
		} else {
			print "Unable to create object";
		}
	}
	print "\n";
}

sub do_write {
	my ($key, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Euro/scraped/$key.txt";

	open my $fh, ">", $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}
