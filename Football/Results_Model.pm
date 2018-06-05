package Football::Results_Model;

use Moo;
use namespace::clean;

use Football::Fixtures_Globals qw(%bbc_fixtures_leagues %bbc_results_leagues);
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
	my ($self, $dataref) = @_;

#	Remove beginning and end of data
	$$dataref =~ s/^.*Content//;
	$$dataref =~ s/All times are UK .*$//g;
	$$dataref =~ s/FT/\n/g;

#	Identify known leagues
	$$dataref =~ s/($leagues)/<LEAGUE>$1\n/g;

#	Work-arounds
#	$self->do_initial_chars ($dataref);
	$self->do_foreign_chars ($dataref);
#	$self->revert ($dataref);

	my @lines = split '\n', $$dataref;
	shift @lines;
	return \@lines;
}

sub after_prepare {
	my ($self, $lines, $day, $dmy) = @_;
	my $csv_league = '';

	for my $line (@$lines) {
		if ($line =~ /<LEAGUE>(.*)$/) {
			$csv_league = (exists $bbc_results_leagues{$1} ) ?
				$bbc_results_leagues{$1} : 'X';
		} else {
			$line =~ s/(\D+)(\d\d?)(\D+)(\d\d?)/$day $dmy,$csv_league,$1,$2,$3,$4/g;
		}
	}
	return $lines;
}

1;
