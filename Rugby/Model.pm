package Rugby::Model;

#	Model.pm 03/02/16 - 14/03/16
#	Mouse version 04/05/16
#	2017 data_model version 09-14/01/17
#	v2.07 with Football::Shared_Model 18-19/01/17
#	v2.12 with Football::Rugby_Data 04/07/17

use List::MoreUtils qw(firstidx);

use Football::Team;
use Rugby::League;
use Rugby::Table;
use Rugby::HomeTable;
use Rugby::AwayTable;
use Rugby::Reports::LeaguePlaces;
use Rugby::Reports::Head2Head;
use Rugby::Reports::Recent_GoalDifference;
use Rugby::Reports::GoalDifference;
use Rugby::Globals qw( @league_names @csv_leagues );

use Moo;
use namespace::clean;

# pre-declare these to use Shared_Model and Rugby_IO roles
has 'leagues' => ( is => 'ro' );
has 'league_names' => ( is => 'ro' );
has 'csv_leagues' => ( is => 'ro' );
has 'model_name' => ( is => 'ro' );
has 'path' => ( is => 'ro' );
has 'fixtures_file' => ( is => 'ro' );
has 'season_data' => ( is => 'ro' );
has 'test_season_data' => ( is => 'ro' ); # Need to add this

with 'Roles::MyJSON',
'Football::Roles::Shared_Model',
'Football::Roles::Rugby_IO_Role';

sub BUILD {
	my $self = shift;
	$self->{leagues} = [];
	$self->{league_names} = \@league_names;
	$self->{csv_leagues} = \@csv_leagues;

	$self->{model_name} = "Rugby";
	$self->{path} = 'C:/Mine/perl/Football/data/Rugby/';
	$self->{fixtures_file} = $self->{path}.'fixtures.csv';
	$self->{season_data} = $self->{path}.'season.json';
	$self->{teams_file} = $self->{path}.'teams.json';
	$self->{results_file} = $self->{path}.'results.ods';
	$self->{test_season_data} = 'C:/Mine/perl/Football/t/test_data/rugby_season.json';
}

sub build_leagues {
	my ($self, $games) = @_;
	my $teams = $self->read_json ($self->{teams_file});
	my $league_array = \@{ $self->{leagues} };
	
	for my $league (@league_names) {
#		die "No games played in $league" if scalar (@ {$games->{$league}} == 0);
		push (@$league_array, Rugby::League->new (
			name		=> $league,
			games		=> $games->{$league},
			team_list	=> \@ { $teams->{$league} },
		));
	}
	return $league_array;
}

sub do_league_places {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_points, $away_points);
	
	my $league_places = Rugby::Reports::LeaguePlaces->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		my $idx = firstidx {$league_name eq $_->{name}} @{$self->{leagues}};

		for my $game (@{ $league->{games}}) {
			$home = $game->{home_team};
			$away = $game->{away_team};

			$game->{home_pos} = $self->{leagues}[$idx]->{teams}->{$home}->{position};
			$game->{away_pos} = $self->{leagues}[$idx]->{teams}->{$away}->{position};
			$game->{results} = $league_places->fetch_array ($league_name, $game->{home_pos}, $game->{away_pos});
		}
	}
	return $fixtures;
}

sub do_head2head {
	my ($self, $fixtures) = @_;
	my ($home, $away, $home_points, $away_points);
	
	my $h2h = Rugby::Reports::Head2Head->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};

		for my $game (@{ $league->{games}}) {
			$home = $game->{home_team};
			$away = $game->{away_team};
			$game->{head2head} = $h2h->fetch ($league_name, $home, $away);

			($home_points, $away_points) = $h2h->calc_points ($game->{head2head});
			$game->{home_h2h} = $home_points;
			$game->{away_h2h} = $away_points;
		}
	}
	return $fixtures;
}

sub do_recent_goal_difference {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_diff, $away_diff, $rgd_div10);
	
	my $goal_diff = Rugby::Reports::Recent_GoalDifference->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		my $idx = firstidx {$league_name eq $_->{name}} @{$self->{leagues}};

		for my $game (@{ $league->{games}}) {
			$home = $game->{home_team};
			$away = $game->{away_team};
			$home_diff = $self->{leagues}[$idx]->{table}->recent_goal_diff ($home);
			$away_diff = $self->{leagues}[$idx]->{table}->recent_goal_diff ($away);
			$game->{recent_goal_difference} = $home_diff - $away_diff;

			$rgd_div10 = int ($game->{recent_goal_difference} / 10);
			$game->{rgd_results} = $goal_diff->fetch_array ($league_name, $rgd_div10);
		}
	}
	return $fixtures;
}

sub do_goal_difference {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_diff, $away_diff, $gd_div10);
	
	my $goal_diff = Rugby::Reports::GoalDifference->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		my $idx = firstidx {$league_name eq $_->{name}} @{$self->{leagues}};

		for my $game (@{ $league->{games}}) {
			$home = $game->{home_team};
			$away = $game->{away_team};

			$home_diff = $self->{leagues}[$idx]->{table}->goal_diff ($home);
			$away_diff = $self->{leagues}[$idx]->{table}->goal_diff ($away);
			$game->{goal_difference} = $home_diff - $away_diff;

			$gd_div10 = int ($game->{goal_difference} / 10);
			$game->{gd_results} = $goal_diff->fetch_array ($league_name, $gd_div10);
		}
	}
	return $fixtures;
}

#	Not implemented by Rugby::Model

sub do_recent_draws {};
sub do_favourites {};
sub do_match_odds {};
sub do_over_under {};

1;
