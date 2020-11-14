
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


sub get_files {
	my $dir = shift;
	my @files = ();

	find (
	  sub {
		  push @files, $_ if $_ =~ /series.*\.csv/;
	  }, $dir
    );
    return \@files;
}

