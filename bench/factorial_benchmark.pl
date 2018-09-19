#!	C:/Strawberry/perl/bin

#	euro_benchmark.pl 19/07/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Benchmark qw(:all);

my $t = timethese ( -20, {
	'check' => sub {
		check ();
	},
	'check2' => sub {
		check2 ();
	},
});

cmpthese $t;

sub check {
	for my $i (0..12) {
		check_it ($i);
	}
}

sub check_it {
	my $number = shift;
	return 1 if $number =~ /^[0|1]$/;
	return 0;
}

sub check2 {
	for my $i (0..12) {
		check_it2 ($i);
	}
}

sub check_it2 {
	my $number = shift;
	return 1 if $number == 1 or $number == 0;
	return 0;
}
