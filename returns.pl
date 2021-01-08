# returns.pl 07/01/21

use MyHeader;
use MyLib qw (read_file);
use Football::Spreadsheets::Write_Returns;

my $returns_rx =
qr/
    \w{2,3}\,       # League ID,
    [\w\h]+\,       # Team,
    \d+,            # Stake
    \d+\.?\d+?,     # Return
    \d+\.?\d+?      # Percentage Return
/x;

my $filename = "c:/mine/lisp/data/returns.csv";
my $lines = read_file ($filename);
my $hash = {};
my $key = "";

for my $line (@$lines) {
	chomp $line;
	if ($line !~ $returns_rx) {
		$key = $line unless $line eq "";
	} else {
		push $hash->{$key}->@*, $line;
	}
}

#print Dumper $hash;
my $xlsx_filename = "c:/mine/perl/Football/reports/returns.xlsx";
print "\nWriting $xlsx_filename...";

my $writer = Football::Spreadsheets::Write_Returns->new (filename => $xlsx_filename);
$writer->write ($hash);

print "\nDone";
