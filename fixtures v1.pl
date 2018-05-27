
#05/05/18
use strict;
use warnings;

use Time::Piece;
use Time::Seconds;
use Web::Query;
use Data::Dumper;
use Football::Globals qw(%bbc_fixtures_leagues);

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

my $str = join '|', keys %bbc_fixtures_leagues;
my $leagues = qr/$str/;
my $time = qr/\d\d:\d\d/;
my $upper = qr/[A-Z]/;
my $lower = qr/[a-z]|÷/;
my $dmy_date = qr/\d\d\/\d\d\/\d\d/;
my $swedish = qr/ FF|IFK | IF| SK/;

my $week = get_week ();
#get_pages ($week);
my $dmy = as_dmy (@$week[0]);

my $path = "C:/Mine/perl/Football/data/Euro/scraped/fixtures test/";
my $filename = "$path/fixtures 2018-05-13.txt";
open my $fh, "<", $filename or die "Can't open $filename";
chomp ( my $data = <$fh> );
close $fh;

my $games = after ( prepare (\$data) );
print Dumper @$games;
#delete_all ($week);

my $out_file = "$path/My Fixtures.csv";
write_csv ($out_file, $games);

sub prepare {
	my $dataref = shift;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK .*$//g;

#	Identify known leagues
	$$dataref =~ s/($leagues)/\n<LEAGUE>$1/g;

#	Work-around to amend Fc and AFC
	$$dataref =~ s/FC/Fc/g;	
	$$dataref =~ s/AFC/Afc/g;
	do_swedish ($dataref);
	
#	Find where team names start	
	$$dataref =~ s/($lower)($upper)(.)/$1\n$dmy,$2$3/g;
	$$dataref =~ s/Fc/FC/g;
	$$dataref =~ s/Afc/AFC/g;
	
#	Replace time with comma for CSV
	$$dataref =~ s/$time/,/g;

	my @lines = split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub do_swedish {
	my $dataref = shift;
	$$dataref =~ s/$swedish//g;
	$$dataref =~ s/G.teborg/Goteborg/g;
	$$dataref =~ s/.rebro/Orebro/g;
	$$dataref =~ s/Malm./Malmo/g;	
}

sub after {
	my $lines = shift;
	my $csv_league = '';
	
	for my $line (@$lines) {
		if ($line =~ /^<LEAGUE>(.*)$/) {
			$csv_league = (exists $bbc_fixtures_leagues{$1} ) ?
				$bbc_fixtures_leagues{$1} : 'X';
		} else {
			$line =~ s/($dmy_date),(.*)/$1,$csv_league,$2/;
		}
	}
	return $lines;
}

sub get_week {
	my @week = ();
	my $today = localtime;
	
#	for my $day (0..7) {
		push @week, ($today + ONE_DAY)->ymd;
#		push @week, ($today + ($day * ONE_DAY))->ymd;
#	}
	return \@week;
}

sub get_pages {
	my $week = shift;
    my ($q, $site);

	for my $date (@$week) {
		$site = "https://www.bbc.co.uk/sport/football/scores-fixtures/$date";
		$q = wq ($site);
		print "\nDownloading $date";
		print "\n$date : ";
		if ($q) {
			do_write ($date, $q->text);
			print "Done - character length : ".length ($q->text());
		} else {
			print "Unable to create object";
		}
	}
	print "\n";
}

sub do_write {
	my ($key, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Euro/scraped/fixtures $key.txt";

	open my $fh, ">", $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

sub delete_all {
	my $week = shift;
	for my $day (@$week) {
		unlink "$path/fixtures $day.txt"
	}
}

sub as_dmy {
	my $date = shift;
	$date =~ s/\d{2}(\d{2})-(\d{2})-(\d{2})/$3\/$2\/$1/;
	return $date;
}

sub write_csv {
	my ($filename, $games) = @_;
	
	open my $fh, ">", $filename or die "Can't open $filename";
	for my $game (@$games) {
		next if $game =~ /^<LEAGUE>/;
		next if $game =~ /,X,/;
		print $fh $game."\n";
	}
	close $fh;
}

#		$q->find('abbr')->replace_with ( sub {
#			$flip ^= 1;
#			return ($flip) ? "<b></b>" : "<b>FT</b>";
#		});
#		$q->find('h3')->replace_with ( "<LEAGUE>");
#		$q->find('h4')->replace_with ( "<LEAGUE>");

#		print Dumper $q->text;
#		$q->find('abbr')->replace_with ( "<b></b>" );
#		$q->find('h4')->replace_with ( "<b>BOLLOX</b>" );
#		$q->find('h4')->each ( sub {
#			my ($i, $elem) = @_; print "\n".Dumper $_;
#		});

