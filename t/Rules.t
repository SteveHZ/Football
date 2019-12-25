#	Rules.t 13/01/18, 21/12/19

use Test2::V0;
plan 2;
use Football::Rules;

my $rules;

subtest 'constructor' => sub {
	plan 1;
	$rules = Football::Rules->new ();
	isa_ok ($rules, ['Football::Rules'], '$rules')
};

subtest 'points' => sub {
	plan 1;
	my $val = $rules->points_rule (16,0);
	is ($val, '16.0', "points = $val");
};
