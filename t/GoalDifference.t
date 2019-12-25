use Test2::V0;
plan 1;

use Football::Reports::GoalDifference;

subtest 'fetch_array' => sub {
	my $obj = Football::Reports::GoalDifference->new ();
	my @gdiffs = (5,-14,106,-112);

	for my $gd (@gdiffs) {
		like ($_, qr/\d+/, "gd = $gd returned $_") for @{ $obj->fetch_array ('Premier League', $gd) };
	}
};
