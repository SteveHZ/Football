#!	C:/Strawberry/perl/bin

#	Rules.t 13/01/18

use strict;
use warnings;
use Test::More tests => 2;
use lib "C:/Mine/perl/Football";

my $rules;

subtest 'constructor' => sub {
	plan tests => 2;
	use_ok 'Football::Rules';
	$rules = Football::Rules->new ();
	isa_ok ($rules, 'Football::Rules', '$rules')
};

subtest 'points' => sub {
	plan tests => 1;
	my $val = $rules->points_rule (16,0);
	is ($val, '16.0', "points = $val"); 
};
