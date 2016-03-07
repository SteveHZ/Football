package Football::LeaguePlaces;

# 	Football::LeaguePlaces.pm 21/02/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Model;
use Football::Table;
use Football::Season;
use Football::Spreadsheets::Reports;

my $path = 'C:/Mine/perl/Football/data/';
my $old_path = 'C:/Mine/perl/Football/data/historical/';
my $league_places_file = $path.'league_places.json';

sub new {
	my ($class, $seasons) = @_;
	
	my $self = {};
	if ($seasons) {
		$self->{hash} = create ($seasons);
	} else {
		$self->{hash} = read_json ($league_places_file);
	}
	bless $self, $class;
	return $self;
}

sub fetch_array {
	my ($self, $home, $away) = @_;
	return [
		$self->{hash}->{$home}->{$away}->{home_win},
		$self->{hash}->{$home}->{$away}->{away_win},
		$self->{hash}->{$home}->{$away}->{draw},
	];
}

sub fetch_hash {
	my ($self, $home, $away) = @_;
	return \%{ $self->{hash}->{$home}->{$away} };
}

sub create {
	my $seasons = shift;
	my $hash = {};
	my $model = Football::Model->new ();
	
	setup ($hash);
	print "\n";
	for my $season (@{ $seasons->{all_seasons} }) {
		print "\nLeague Places - Updating $season...";

		my $json_file = $old_path.$season.'.json';
		my $games = read_json ($json_file);
		my $all_teams = $model->get_all_teams ($games);
		my $table = Football::Table->new ($all_teams);
		my $teams = {};
		my $week = 0;
		
		for my $game (@$games) {
			if ($game->{week} > $week) {
				$week ++;
				my $sorted = $table->sort_table ();
				my $idx = 1;
				for my $team (@$sorted) {
					my $name = $team->{team};
					$teams->{$name}->{position} = $idx ++;
				}
			}
			my $result = get_result ($game->{home_score}, $game->{away_score});
			my $home = $game->{home_team};
			my $away = $game->{away_team};
			my $home_pos = $teams->{$home}->{position};
			my $away_pos = $teams->{$away}->{position};

			if ($result eq 'H') { $hash->{$home_pos}->{$away_pos}->{home_win} ++; }
			elsif ($result eq 'A') { $hash->{$home_pos}->{$away_pos}->{away_win} ++; }
			else { $hash->{$home_pos}->{$away_pos}->{draw} ++; }

			$table->update ($game);
		}
	}
	write_json ($league_places_file, $hash);
	write_report ($hash);
	return $hash;
}

sub setup {
	my $hash = shift;
	for my $home (1..20) {
		for my $away (1..20) {
			next if ($home == $away);
			$hash->{$home}->{$away} = setup_results ();
		}
	}
}

sub setup_results {
	return {
		home_win => 0,
		away_win => 0,
		draw => 0,
	};
}

sub get_result {
	my ($home, $away) = @_;
	
	return 'H' if $home > $away;
	return 'A' if $home < $away;
	return 'D';		#	if $home > 0;#	return 'N';
}

sub write_report {
	my $hash = shift;
	
	my $writer = Football::Spreadsheets::Reports->new ("League Places");
	$writer->do_league_places($hash);
}

1;