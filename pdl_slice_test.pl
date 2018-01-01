use strict;
use warnings;
use PDL;

my $zz= zeroes(6,6);
print $zz;
my $x=$zz;

$zz->slice('2:3','3:4').=12;
#$zz->slice(2,3).=12;
#my $sl = $zz->slice(2,3);
#$sl.=12;
print $zz;
print $x;
