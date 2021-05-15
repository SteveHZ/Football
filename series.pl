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

=begin comment

# original version

# series.pl 28/08/20 - 01/09/20

use MyHeader;
use File::Find;
use Football::Spreadsheets::Write_Series;

my $path = "c:/mine/lisp/data";
my @pages = ("Wins", "Home Wins", "Away Wins",
			 "Draws", "Home Draws", "Away Draws",
			 "Defeats", "Home Defeats", "Away Defeats");

my $files = get_files ($path);

for my $file (@$files) {
	my $hash = {};
	my $page = 0;

	open my $fh, '<', "$path/$file" or die "Can't open $file";
	while (my $line = <$fh>) {
		chomp $line;

		if ($line ne "") {
			push $hash->{ $pages [$page] }->@*, $line;
		} else {
			$page ++;
		}
	}
	close $fh;

	my ($name, $junk) = split '\.', $file;
	my $xlsx_filename = "C:/Mine/perl/Football/reports/$name.xlsx";
	print "\nWriting $xlsx_filename...";
	my $writer = Football::Spreadsheets::Write_Series->new (filename    => $xlsx_filename,
															sheet_names => \@pages);
	$writer->write ($hash);
	print "Done";
}

=end comment
=cut
