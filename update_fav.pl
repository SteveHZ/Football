#!	C:/Strawberry/perl/bin

#	17/11/16
#	Read all results in, add a number of games for each "week"
#	to a running array for each league
# 	then pass each league to update for each week
#	call fav_model->update (see model->do_favourites)
#	data will be returned in fav_model->hash () 

#	write out to a spreadsheet to check looks ok
#	then write to json

use strict;
use warnings;

use Football::Favourites_Model;
use Football::Favourites_Data_Model;
#use Football::Season;
use List::MoreUtils qw(each_array);
use Data::Dumper;

my $year = 2016;
my $num_weeks = 13;
my $path = 'C:/Mine/perl/Football/data/fav_copy/';
my @leagues = (	"Premier League", "Championship", "League One", "League Two", "Conference",
				"Scots Premier", "Scots Championship", "Scots League One", "Scots League Two",
);
#my @csv_leagues = qw(E0 E1 E2 E3 EC SC0 SC1 SC2 SC3);
#my @league_size = (20,24,24,24,24,12,10,10,10); # clubs in each league
my $num_games = {
	'Premier League' 	=> [ 0,10,10,10,0,10,10,10,10,0,10,10,10], #started 13/08
	'Championship' 		=> [12,12,24,12,0,24,12,24,12,0,24,12,12], #started 05/08
};

main ();

sub main {
	my $fav_model = Football::Favourites_Model->new ();
	my $data = read_files ();

	for my $week (0..$num_weeks - 1) {
	
	}
	for my $league (@leagues) {
		print Dumper ($data->{$league}); <STDIN>;
	}
}	

sub read_files {
	my $data_model = Football::Favourites_Data_Model->new ();
	my $data = {};

	for my $league (@leagues) {
		my $file = $path.$league.".csv";
		$data->{$league} = $data_model->update ($file);
	}
	return $data;
}

#		my $data = $data_model->update_current ($file_from, $csv_league);
#		$data_model->write_current ($file_to, $data);
#		$fav_model->update ($league, $year, $data);
#	return {
#		data => $fav_model->hash (),
#		leagues => \@leagues,
#		year => $year,
#	};

=head
			my $week = 0;
			my $games = $data_model->update ($csv_file);

			for my $game (@$games) {
				if ($week == 0) {
					$week = 1;
					$week_counter = Football::Season->new (
						start_date => $game->{date},
						league_size => $size
					);
				} else {
					$week = $week_counter->check ($game->{date});
				}
				$game->{week} = $week;
			}
			$json_file = $historical_path.$league.'/'.$season.'.json';
			$self->write_json ($json_file, $games);
		}
	}

sub update {
	my ($self, $league, $year, $results) = @_;
	$self->{hash}->{$league}->{$year} = $self->setup ();

	for my $game (@$results) {
		$self->{hash}->{$league}->{$year}->{stake} ++;
		if ($game->{result} eq 'D') {
			$self->{hash}->{$league}->{$year}->{draw_winnings} += $game->{draw_odds};
		} elsif ($game->{home_odds} > $game->{away_odds}) {
			if ($game->{result} eq 'H'){
				$self->{hash}->{$league}->{$year}->{under_winnings} += $game->{home_odds};
			} else {
				$self->{hash}->{$league}->{$year}->{fav_winnings} += $game->{away_odds};
			}
		} else {
			if ($game->{result} eq 'A'){
				$self->{hash}->{$league}->{$year}->{under_winnings} += $game->{away_odds};
			} else {
				$self->{hash}->{$league}->{$year}->{fav_winnings} += $game->{home_odds};
			}
		}
	}
}
=cut