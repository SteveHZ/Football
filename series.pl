# series.pl 18-24/10/20

use MyHeader;
use MyLib qw(read_file);
use Football::Globals qw($reports_folder);
use Football::Spreadsheets::Write_Series;

my @series_name = qw(s1 s246 s369 stoffo);
my $series_rx = qr/
    \w{2,3}\,   # League ID,
    [\w\h]+\,   # Team,
    \d+         # Stake, Return and Percentage
/x;

my $country;
if (! defined $ARGV[0]) {
	$country = "UK";
} else {
	$country = "Summer" if $ARGV[0] eq '-s';
	$country = "Euro" if $ARGV[0] eq '-e';
	die "\nDied with invalid argument '$ARGV[0]'" if (! defined $country);
}

sub build_hash {
	my $lines = shift;
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
	return $hash;
}

for my $series (@series_name) {
	my $lines = read_file ("c:/mine/lisp/data/series $series $country.csv");
	my $hash = build_hash ($lines);

	my $xlsx_filename = "$reports_folder/series $series $country.xlsx";
	print "\nWriting $xlsx_filename...";

	my $writer = Football::Spreadsheets::Write_Series->new (filename => $xlsx_filename);
	$writer->write ($hash);
}

print "\nDone\n";
