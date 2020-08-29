
# series.pl 28/09/20

use MyHeader;

my $line;
my $page = 0;
my $hash = {};
my @pages = ("Wins", "Home Wins", "Away Wins", "Draws", "Home Draws", "Away Draws");

open my $fh, '<','c:/mine/lisp/data/series.csv';
while ($line = <$fh>) {
	$line =~ s/","/"\n"/g;  # change commas in between closing and opening quotes into new lines
	$line =~ s/"//g;        # now remove quotes
	$hash->{$pages [$page ++]} = [ split "\n", $line ];
}

print Dumper $hash;
