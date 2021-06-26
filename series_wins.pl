#	series_wins.pl 24/06/21

use MyHeader;
use List::Util qw(sum);

my $odds = 1.9;
my @series_list = (
	[1,2,3,4,5,6],
	[2,3,4,5,6,8],
	[2,3,5,6,8,10],
#	[1,2,4,6,8,12],
#	[11,22,44,66,88,132],
);
my @wins_list = (
	[1,2], [1,3], [1,4], [1,5], [1,6],
	[2,3], [2,4], [2,5], [2,6],
	[3,4], [3,5], [3,6],
	[4,5], [4,6],
	[5,6],
);

for my $series (@series_list) {
	print_array ($series);
	
	for my $wins (@wins_list) {
		my $first_win_idx  = @$wins [0] - 1;
		my $second_win_idx = @$wins [1] - 1;

		my $first_win  = @$series [$first_win_idx];
		my $second_win = @$series [$second_win_idx];
		my $return = $odds * ($first_win + $second_win);

		my $stake = sum (@$series [0..$second_win_idx]);
		my $profit = $return - $stake;

		print "\n@$wins[0],@$wins[1] : ";
		printf "stake = %2d\t%2d", $stake, $return;
		print "\t$profit" if $return > $stake;
	}
}

sub print_array ($series) {
	print "\n\n[";
	print join ',',@$series;
	print "]\n";
}
