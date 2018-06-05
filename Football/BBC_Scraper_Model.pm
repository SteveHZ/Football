package Football::BBC_Scraper_Model;

use Moo;
use namespace::clean;

use Time::Piece;
use Time::Seconds;
use Web::Query;
use utf8;
#use Football::Fixtures_Globals qw(%bbc_fixtures_leagues);
#use MyRegX;
use Data::Dumper;

$Web::Query::UserAgent = LWP::UserAgent->new (
    agent => 'Mozilla/5.0',
);

=head
my $str = join '|', keys %bbc_fixtures_leagues;
my $leagues = qr/$str/;

my $rx = MyRegX->new ();
my $time = $rx->time;
my $upper = $rx->upper;
my $lower = $rx->lower;
my $dmy_date = $rx->dmy_date;

#my $upper = qr/[A-Z]/;
#my $lower = qr/[a-z]/;
#my $lower = qr/[a-z]|รท/;

sub prepare {
	my ($self, $dataref, $day, $dmy) = @_;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK .*$//g;

#	Identify known leagues
	$$dataref =~ s/($leagues)/\n<LEAGUE>$1/g;

#	Work-arounds
	$self->do_initial_chars ($dataref);
	$self->do_foreign_chars ($dataref);
	
#	Find where team names start	
	$$dataref =~ s/($lower)($upper)(.)/$1\n$day $dmy,$2$3/g;

#	Undo SOME workarounds
	$self->revert ($dataref);
	
#	Replace time with comma for CSV
	$$dataref =~ s/$time/,/g;

	my @lines = split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub prepare2 {
	my ($self, $dataref, $day, $dmy) = @_;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK .*$//g;

#	Identify known leagues
	$$dataref =~ s/($leagues)/\n<LEAGUE>$1<\/LEAGUE>\n/g;

#	Work-arounds
	$self->do_initial_chars ($dataref);
	$self->do_foreign_chars ($dataref);
#print $$dataref;<STDIN>;	
#	Find where team names start	
#	$$dataref =~ s/($lower)($upper)(.)/$1\n$day $dmy,$2$3/g;
$$dataref =~ s/FT/ $day $dmy\n/g;
#$$dataref =~ s/>(\D+)(\d\d?)(\D+)(\d\d?)FT/\n$day $dmy,$1,$2,$3,$4/g;
#$$dataref =~ s/(\D+)(\d\d?)(\D+)(\d\d?)/\n$day $dmy,$1,$2,$3,$4/g;
#$$dataref =~ s/FT/\n/g;

#	Undo SOME workarounds
	$self->revert ($dataref);
#print $$dataref;<STDIN>;	

	my @lines = split '\n', $$dataref;
	shift @lines;
#print Dumper @lines;<STDIN>;
	return \@lines;
}

sub after_prepare {
	my ($self, $lines) = @_;
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

sub after_prepare2 {
	my ($self, $lines) = @_;
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

=cut
sub get_week {
	my ($self, $days, $forwards) = @_;
	$days //= 10;
	$forwards //= 1;
	
	my @week = ();
	my $today = localtime;
	
	for my $day_count (1..$days) {
		my $day = ($forwards) ? 
			$today + ($day_count * ONE_DAY):
			$today - ($day_count * ONE_DAY);
		push @week, {
			day	 => $day->wdayname,
			date => $day->ymd,
		};
	}
	return \@week;
}

sub get_reverse_week {
	my ($self, $days) = @_;
	$days //= 10;
	$self->get_week ($days, 0);
}

sub get_pages {
	my ($self, $site, $week) = @_;

	for my $date (@$week) {
		my $q = wq ("$site/$date->{date}");
		$q->find ('abbr')
		  ->filter ( sub { $_->text ne 'FT' } )
		  ->replace_with ( '<b></b>' );

		print "\nDownloading $date->{date}";
		print "\n$date->{date} : ";
		if ($q) {
			$self->do_write ($date->{date}, $q->text);
			print "Done - character length : ".length ($q->text());
		} else {
			print "Unable to create object";
		}
	}
	print "\n";
}

sub do_write {
	my ($self, $date, $txt) = @_;
	my $filename = "C:/Mine/perl/Football/data/Euro/scraped/fixtures $date.txt";

	open my $fh, ">", $filename or die "Can't open $filename";
	print $fh $txt;
	close $fh;
}

sub delete_all {
	my ($self, $path, $week) = @_;
	for my $day (@$week) {
		unlink "$path/fixtures $day->{date}.txt"
	}
}

sub as_dmy {
	my ($self, $date) = @_;
	$date =~ s/\d{2}(\d{2})-(\d{2})-(\d{2})/$3\/$2\/$1/;
	return $date;
}

sub do_foreign_chars {
	my ($self, $dataref) = @_;
	$$dataref =~ s/ä/a/g;
	$$dataref =~ s/å/a/g;
	$$dataref =~ s/ö/o/g;
	$$dataref =~ s/Ö/O/g;
	$$dataref =~ s/ø/o/g;
	$$dataref =~ s/æ/ae/g;
	$$dataref =~ s/\// /g;
}

sub do_initial_chars {
	my ($self, $dataref) = @_;
	$$dataref =~ s/FC/Fc/g;	
	$$dataref =~ s/AFC/Afc/g;
#	Order is important here !
	$$dataref =~ s/ FF//g;	
	$$dataref =~ s/IFK //g;	
	$$dataref =~ s/FK //g;	
	$$dataref =~ s/ FK//g;	
	$$dataref =~ s/GIF //g;	
	$$dataref =~ s/ IF//g;	
	$$dataref =~ s/IF //g;	
	$$dataref =~ s/IK //g;	
	$$dataref =~ s/ SK//g;	
	$$dataref =~ s/BK //g;	
	$$dataref =~ s/ BK//g;	
	$$dataref =~ s/ SC//g;	
	$$dataref =~ s/ 08//g;	
	$$dataref =~ s/AIK/AIk/g;
	$$dataref =~ s/KuPS/KUPS/g;
	$$dataref =~ s/RoPS //g;
}

sub revert {
	my ($self, $dataref) = @_;
	$$dataref =~ s/Fc/FC/g;
	$$dataref =~ s/Afc/AFC/g;
	$$dataref =~ s/AIk/AIK/g;
	$$dataref =~ s/KUPS/KuPS/g;
}

1;
