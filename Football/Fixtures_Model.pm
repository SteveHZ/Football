package Football::Fixtures_Model;

use Moo;
use namespace::clean;

use Football::Fixtures_Globals qw(%bbc_fixtures_leagues);
use MyRegX;

extends 'Football::Web_Scraper_Model';

my $str = join '|', keys %bbc_fixtures_leagues;
my $leagues = qr/$str/;

my $rx = MyRegX->new ();
my $time = $rx->time;
my $upper = $rx->upper;
my $lower = $rx->lower;
my $dmy_date = $rx->dmy_date;

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
	$$dataref =~ s/($lower)($upper)/$1\n$day $dmy,$2/g;

#	Undo SOME workarounds
	$self->revert ($dataref);
	
	$$dataref =~ s/($time)/,$1,/g;

	my @lines = split '\n', $$dataref;
	shift @lines;
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
			$line =~ s/($dmy_date),(.*),($time),(.*)/$1 $3,$csv_league,$2,$4/;
		}
	}
	return $lines;
}

1;
