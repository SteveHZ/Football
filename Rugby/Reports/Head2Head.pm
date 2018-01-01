package Rugby::Reports::Head2Head;

# 	Rugby::Reports::Head2Head.pm 21/02/16
#	v1.1 07/05/17

use List::MoreUtils qw(each_arrayref);
use Rugby::Table;
use Football::Season;
use Rugby::Rugby_Data_Model;

use Moo;
use namespace::clean;

extends 'Football::Reports::Head2Head';

sub get_paths {
	my $self = shift;
	$self->{path} = 'C:/Mine/perl/Football/data/Rugby/';
	$self->{historical_path} = 'C:/Mine/perl/Football/data/Rugby/historical/';
	$self->{h2h_file} = $self->{path}.'head2head.json';
}

# 	Only difference between these 2 methods and the Football H2H methods
#	is in the folder structure that is being read - maybe change Rugby Archive script ?

sub csv_to_json {
	my ($self, $leagues, $league_size, $seasons) = @_;
	my ($csv_file, $json_file, $week_counter);
	my $data_model = Rugby::Rugby_Data_Model->new ();
	my $iterator = each_arrayref ($leagues, $league_size);

	while ( my ($league, $size) = $iterator->() ) {
		for my $season (@ { $seasons->{$league} }) {
			print "\nCSV to JSON - Updating $league - $season...";
			$csv_file = $self->{historical_path}.$season.'/'.$league.".csv";
			my $week = 0;
			my $games = $data_model->read_archived ($csv_file);

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
			$json_file = $self->{historical_path}.$season.'/'.$league.'.json';
			$self->write_json ($json_file, $games);
		}
	}
}

sub build_head2head {
	my ($self, $leagues, $teams, $seasons) = @_;
	my $idx;

	print "\n";
	for my $league (@$leagues) {
		for my $season (@{ $seasons->{h2h_seasons} }) {
			print "\nHead To Head - Updating $league - $season...";
			my $json_file = $self->{historical_path}.$season.'/'.$league.'.json';
			my $games = $self->read_json ($json_file);

			for my $game (@$games) {
				my $home_team = $game->{home_team};
				my $away_team = $game->{away_team};
				my $result = $self->get_result ($game->{home_score}, $game->{away_score});
				if (exists ($teams->{$league}->{$home_team}) &&
					exists ($teams->{$league}->{$away_team} )) {
					$idx = $season - @{ $seasons->{h2h_seasons} }[0];
					$teams->{$league}->{$home_team}->{$away_team}->[$idx] = $result;
				}
			}
		}
	}
	$self->write_json ($self->{h2h_file}, $teams);
	return $teams;
}

sub calc_points {
	my ($self, $stats) = @_;
	my ($home, $away) = (0,0);
	
	for my $result (@$stats) {
		if ($result eq 'H') 	{ $home += 2; }
		elsif ($result eq 'A') 	{ $away += 2; }
		elsif ($result ne 'X')	{ $home ++; $away ++; }
	}
	return ($home, $away);
}

1;
