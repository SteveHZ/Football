
# 	read_fixtures.pl 12/03/16 - 15/03/16
#	rewritten 15/03 to copy from a fixtures_test xls sheet
#	copied from Dedicated Excel fixtures

use strict;
use warnings;
use Spreadsheet::Read qw(ReadData rows);

my $fixture_path = 'C:/Mine/perl/Football/data/';
my $txt_file = $fixture_path.'fixtures.txt';
my $xls_file = $fixture_path.'fixtures.xls';
#my $csv_file = $fixture_path.'fixtures_test.csv';

main ();

sub main {
	my (@fixtures);

	my $book = ReadData ($xls_file);
	my @rows = rows ($book->[1]);

	for my $match (@rows) {
		push ( @fixtures, {
			home => @$match [0],
			away => @$match [1],
		});
	}

	open (my $fh_out, '+>', $txt_file)
		or die "\n Can't open data $txt_file !!";

	print "\nWriting...";
	for my $fixture (@fixtures) {
		print "\n$fixture->{home} v $fixture->{away}";
		print $fh_out "$fixture->{home},$fixture->{away}\n";
	}
	close $fh_out;
	print "\n";
}

=head2
	open (my $fh_in, '<', $csv_file) or die ("Can't find $csv_file");
	my $line = <$fh_in>;
	while ($line = <$fh_in>) {
		my ($league, $junk, $home, $away, @junk) = split (/,/, $line);
		if ($league eq 'E0') {
			push ( @fixtures, {
				home => $home,
				away => $away,
			});
		}
	}
	close $fh_in;
=cut
