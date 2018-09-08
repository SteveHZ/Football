package Football::Reports::Head2Head;

# 	Football::Head2Head.pm 21/02/16
#	v1.1 07/05/17

use List::MoreUtils qw(each_arrayref);
use Football::Table;
use Football::Season;
use Football::Football_Data_Model;

use Moo;
use namespace::clean;

extends 'Football::Reports::Base';
with 'Roles::MyJSON';

sub BUILD {
	my ($self, $args) = @_;

	$self->get_paths ();
	unless ($args->{seasons}) {
		$self->{hash} = $self->read_json ( $self->{h2h_file} );
	} elsif ($args->{all_teams}) {
		$self->{hash} = $self->create ( $args->{leagues}, $args->{league_size},
										$args->{all_teams}, $args->{seasons} );
	} else {
		die "Problem creating Head2Head object !!";
	}
}

sub get_paths {
	my $self = shift;
	$self->{path} = 'C:/Mine/perl/Football/data/';
	$self->{historical_path} = 'C:/Mine/perl/Football/data/historical/';
	$self->{h2h_file} = $self->{path}.'head2head.json';
}

sub fetch {
	my ($self, $league, $home, $away) = @_;
	return \@{ $self->{hash}->{$league}->{$home}->{$away} };
}

sub create {
	my ($self, $leagues, $league_size, $all_teams, $seasons) = @_;

	$self->csv_to_json ($leagues, $league_size, $seasons);
	my $teams = create_hash ($leagues, $all_teams, $seasons);
	return $self->build_head2head ($leagues, $teams, $seasons);
}

sub csv_to_json {
	my ($self, $leagues, $league_size, $seasons) = @_;
	my ($csv_file, $json_file, $week_counter);
	my $data_model = Football::Football_Data_Model->new ();
	my $iterator = each_arrayref ($leagues, $league_size);

	while ( my ($league, $size) = $iterator->() ) {
		for my $season (@ { $seasons->{$league} }) {
			print "\nCSV to JSON - Updating $league - $season...";
			$csv_file = $self->{historical_path}.$league.'/'.$season.".csv";
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
			$json_file = $self->{historical_path}.$league.'/'.$season.'.json';
			$self->write_json ($json_file, $games);
		}
	}
}

sub create_hash {
	my ($leagues, $all_teams, $seasons) = @_;
	my $teams = {};

	print "\n";
	for my $league (@$leagues) {
		print "\nCreating hash for $league...";
		for my $home (@ {$all_teams->{$league} }) {
			for my $away (@ {$all_teams->{$league} }) {
				for my $season (@{ $seasons->{h2h_seasons} }) {
					@{ $teams->{$league}->{$home}->{$away} } = qw(X X X X X X) unless $home eq $away;
				}
			}
		}
	}
	return $teams;
}

sub build_head2head {
	my ($self, $leagues, $teams, $seasons) = @_;
	my $idx;

	print "\n";
	for my $league (@$leagues) {
		for my $season (@{ $seasons->{h2h_seasons} }) {
			print "\nHead To Head - Updating $league - $season...";
			my $json_file = $self->{historical_path}.$league.'/'.$season.'.json';
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
		if ($result eq 'H') 	{ $home += 3; }
		elsif ($result eq 'A') 	{ $away += 3; }
		elsif ($result ne 'X')	{ $home ++; $away ++; }
	}
	return ($home, $away);
}

1;
