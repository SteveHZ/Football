# series.pl 18-24/10/20

use MyHeader;
use MyLib qw (read_file);
use Football::Spreadsheets::Write_Series;

my @series_name = qw(s1 s2 s3 s4 s5 s6);
my $series_rx = qr/
    \w{2,3}\,   # League ID,
    [\w\h]+\,   # Team,
    \d+         # Return
/x;

for my $series (@series_name) {
	my $lines = read_file ("c:/mine/lisp/data/series $series.csv");
	my $hash = {};
	my $key = "";

	for my $line (@$lines) {
		chomp $line;
		if ($line !~ $series_rx) {
			$key = $line unless $line eq "";
		} else {
			push $hash->{$key}->@*, $line;
		}
	}

	my $xlsx_filename = "c:/mine/perl/Football/reports/series $series.xlsx";
	print "\nWriting $xlsx_filename...";

	my $writer = Football::Spreadsheets::Write_Series->new (filename => $xlsx_filename);
	$writer->write ($hash);
}

print "\nDone";
