#	Season.t 01/05/16
#	v2 05/06/15

use strict;
use warnings;
use Test::More tests => 1;

use lib 'C:/Mine/perl/Football';
use Football::Season;
use Football::Football_Data_Model;

my $path = 'C:/Mine/perl/Football/data/historical/Premier League/';
my $csv_file = $path.'2014.csv';

my $league_size = 20;
my $week = 0;
my $week_counter;

my $data_model = Football::Football_Data_Model->new ();
my $games = $data_model->update ($csv_file);

subtest '42 weeks' => sub {
	my $weeks = count_weeks ($games);
	ok ($weeks == 42, 'number of weeks is 42');

	sub count_weeks {
		my $games = shift;
		for my $game (@$games) {
			if ($week == 0) {
				$week = 1;
				$week_counter = Football::Season->new (
					start_date => $game->{date},
					league_size => $league_size
				);
				isa_ok ($week_counter, 'Football::Season', '$week_counter');
			} else {
				$week = $week_counter->check ($game->{date});
			}
		}
		return $week;
	}
};
