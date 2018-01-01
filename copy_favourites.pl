#!	C:/Strawberry/perl/bin

use strict;
use warnings;
use File::Copy;

my $path = 'C:/Mine/perl/Football/reports/favourites/';
my $copy_from = $path."current.xlsx";
my $copy_to = $path."last_week.xlsx";

if (-e $copy_from) {
	copy $copy_from, $copy_to;
	print "Copied from $copy_from to $copy_to";
} else {
	print "Unable to find $copy_from";
}
