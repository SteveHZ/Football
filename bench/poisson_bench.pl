use Benchmark qw(:all);
use Football::Game_Predictions::Match_Odds;

# To benchmark correctly, need to remove return hash statement from calc_odds,
# but pure perl version still appears to be faster than C ??

my $home_expect = 2.02;
my $away_expect = 0.53;
my $odds = Football::Game_Predictions::Match_Odds->new (max => 5, weighted => 1);

my $t = timethese ( -20, {
	'perl' => sub {
        $odds->calc ($home_expect, $away_expect)
	},
	'cdf' => sub {
        $odds->calc_odds ($home_expect, $away_expect);
	},
});
cmpthese $t;
