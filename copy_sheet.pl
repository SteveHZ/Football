#!	C:/Strawberry/perl/bin

#	11/07/17

use strict;
use warnings;

use Spreadsheet::Read qw(rows);
use Data::Dumper;

main ();

sub main {
	my $in_path = "C:/Mine/perl/Football/reports/Euro/";
	my $out_path = $in_path."Archive/";
	my $in_file = $in_path."goal_expect.ods";
	my $out_file = $out_path."July 2017.ods";
	
	my $sheet_data = get_sheet ($in_file,1);
print Dumper $sheet_data;
}

sub get_sheet {
	my ($filename, $sheet) = @_;

	print "\nReading $filename...";
	my $book = Spreadsheet::Read->new ($filename);
	die "\nProblem reading $filename" unless $book->sheets;
	
	my @rows = rows ($book->[$sheet]);
	return \@rows;
}
