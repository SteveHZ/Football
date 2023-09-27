# backtest.pl 16/02/20, 20/07/23

use MyHeader;
use Football::Globals qw(@league_names);
use Football::BackTest::Model;

my $model = Football::BackTest::Model->new ();
my $dbh = $model->connect (dir => 'C:/Mine/perl/Football/data/backtest');
my $totals = {};

for (my $my_expect_odds = 1.2; $my_expect_odds < 1.8; $my_expect_odds += 0.1) {
#	for (my $b365_odds = 1.2; $b365_odds < 2; $b365_odds += 0.1) {
	my $b365_odds = 1.9;
		for my $query (get_queries ($my_expect_odds, $b365_odds)->@*) {
			my $stake = {};
			my $wins = {};
			$totals->{stake} = 0;
			$totals->{wins} = 0;

			for my $league (@league_names) {
				$stake->{$league} = 0;
				$wins->{$league} = 0;

				$model->do_query (
					league => $league,
					data => { stake => $stake, wins => $wins, totals => $totals },
					query => $query->{query},
					callback => sub { $query->{callback}->(@_) },
				);
			}
			if ($totals->{stake} > 0) {
				say "\n\n$query->{query} :";
				printf "Total Stake = %4d \tTotal Wins = %8.2f \tRatio = %0.2f",
					$totals->{stake}, $totals->{wins}, $totals->{wins} / $totals->{stake};
			}
			for my $league (@league_names) {
				if ($stake->{$league}) {
					printf "\nLeague = %-20s Stake = %4d \tWins = %8.2f \tRatio = %0.2f",
						$league, $stake->{$league}, $wins->{$league}, $wins->{$league} / $stake->{$league};
				}
			}
		}
	}
#}

say "";
$model->disconnect ();

sub get_queries {
	my ($my_expect_odds, $b365_odds) = @_;
	return [
		{	
			query => "season_over <= $my_expect_odds AND b365over <= $b365_odds", # my expect odds and b365 odds
			callback => sub {
				my ($row, $league, $data) = @_;
				if ($row->{home_score} + $row->{away_score} > 2.5) { # over 2.5 result
					$data->{wins}->{$league} += $row->{b365over};
					$data->{totals}->{wins} += $row->{b365over};
				}
			},
		},
# 		{	
#			query => "recent_over <= 1.5 AND b365over <= 1.8", # my expect odds and b365 odds
#			callback => sub {
#				my ($row, $league, $data) = @_;
#				if ($row->{home_score} + $row->{away_score} > 2.5) { # over 2.5 result
#					$data->{wins}->{$league} += $row->{b365over};
#					$data->{totals}->{wins} += $row->{b365over};
#				}
#			},
#		},
#		{	
#			query => "season_under <= 1.5 AND b365under <= 1.8", # my expect odds and b365 odds
#			callback => sub {
#				my ($row, $league, $data) = @_;
#				if ($row->{home_score} + $row->{away_score} < 2.5) { # under 2.5 result
#					$data->{wins}->{$league} += $row->{b365under};
#					$data->{totals}->{wins} += $row->{b365under};
#				}
#			},
#		},
#		{	
#			query => "recent_under <= 1.5 AND b365under <= 1.8", # my expect odds and b365 odds
#			callback => sub {
#				my ($row, $league, $data) = @_;
#				if ($row->{home_score} + $row->{away_score} < 2.5) { # under 2.5 result
#					$data->{wins}->{$league} += $row->{b365under};
#					$data->{totals}->{wins} += $row->{b365under};
#				}
#			},
#		},
    ];
}
