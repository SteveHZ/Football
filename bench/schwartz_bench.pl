#!	C:/Strawberry/perl/bin

# 	schwartz_bench.pl 21/05/16
#	Benchmarking the schwartzian sort routine in half_full.pl
#	against the original version

use strict;
use warnings;
use Benchmark qw(:all);

my $hash = {
	'0-0' => 0, '1-1' => 0, '2-0' => 0, '1-4' => 0, '1-5' => 0, '2-2' => 0,
	'1-0' => 0, '2-3' => 0, '0-1' => 0, '1-2' => 0, '0-2' => 0, '1-3' => 0,
	'0-3' => 0, '2-1' => 0, '0-4' => 0,
};

my $t = timethese ( -10, {
	"Schwartzian 1" => sub {
		my @sorted_hash =
			map  { $_->[0] }
			sort { $a->[1] <=> $b->[1] or
				   $a->[2] <=> $b->[2] }
			map  { [ $_, split ('-', $_) ] }
			keys (%$hash);
		return \@sorted_hash;
	},
	"Schwartzian 2" => sub {
		return [
			map  { $_->[0] }
			sort { $a->[1] <=> $b->[1] or
				   $a->[2] <=> $b->[2] }
			map  { [ $_, split ('-', $_) ] }
			keys (%$hash)
		];
	},
	"Simpler sort routine" => sub {
		my @temp = sort {
			my ($a1, $a2) = split ('-', $a);
			my ($b1, $b2) = split ('-', $b);
			$a1 <=> $b1 or $a2 <=> $b2
		} keys (%$hash);
		return \@temp;
	}
});

cmpthese $t;
