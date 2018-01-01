package Football::Model;

#	Football::Model.pm 03/02/16 - 14/03/16
# 	v2.0 23-28/03/16, v2.01 Mouse 04/05/16, v2.02 Football_Data_Model 27/05/16 v2.03 26-27/07/16
#	v2.06 Moo 01/10/16
#	v2.07 with Football::Shared_Model 18-19/01/17
	
use List::MoreUtils qw(firstidx each_array);

use Football::League;
use Football::Team;
use Football::Table;
use Football::HomeTable;
use Football::AwayTable;

use Football::Favourites_Data_Model;
use Football::Favourites_Model;
use Football::Favourites_View;

use Football::Reports::Head2Head;
use Football::Reports::LeaguePlaces;
use Football::Reports::GoalDifference;
use Football::Reports::Recent_GoalDifference;
use Football::Globals qw( @league_names @csv_leagues $default_stats_size );

use Moo;
use namespace::clean;

# pre-declare these to use Shared_Model and Football_IO roles
has 'leagues' => ( is => 'ro' );
has 'league_names' => ( is => 'ro' );
has 'csv_leagues' => ( is => 'ro' );
has 'model_name' => ( is => 'ro' ); # not used here but required for roles
has 'path' => ( is => 'ro' );
has 'fixtures_file' => ( is => 'rw' );
has 'season_data' => ( is => 'ro' );
has 'test_season_data' => ( is => 'ro' );

with 'Roles::MyJSON',
'Football::Roles::Shared_Model',
'Football::Roles::Football_IO_Role';

sub BUILD {
	my $self = shift;
	$self->{leagues} = [];
	$self->{league_names} = \@league_names;
	$self->{csv_leagues} = \@csv_leagues;

	$self->{model_name} = "Football";
	$self->{path} = 'C:/Mine/perl/Football/data/';
	$self->{fixtures_file} = $self->{path}.'fixtures.csv';
	$self->{season_data} = $self->{path}.'season.json';
	$self->{teams_file} = $self->{path}.'teams.json';
	$self->{test_season_data} = 'C:/Mine/perl/Football/t/test_data/season.json';
}

sub build_leagues {
	my ($self, $games) = @_;
	my $teams = $self->read_json ( $self->{teams_file} );

	for my $league (@{ $self->{league_names} } ) {
#		die "No games played in $league" if scalar (@ {$games->{$league}} == 0);
		push (@{ $self->{leagues} }, Football::League->new (
			title		=> $league,
			games 		=> $games->{$league},
			team_list	=> $teams->{$league},
		));
	}
	return $self->{leagues};
}

sub do_league_places {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_points, $away_points);
	
	my $league_places = Football::Reports::LeaguePlaces->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		my $idx = firstidx {$league_name eq $_->{title}} @{$self->{leagues}};

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
	
	my $h2h = Football::Reports::Head2Head->new ();
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
	my ($home, $away, $home_diff, $away_diff);
	
	my $goal_diff = Football::Reports::Recent_GoalDifference->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		my $idx = firstidx {$league_name eq $_->{title}} @{$self->{leagues}};

		for my $game (@{ $league->{games}}) {
			$home = $game->{home_team};
			$away = $game->{away_team};
			$home_diff = $self->{leagues}[$idx]->{table}->recent_goal_diff ($home);
			$away_diff = $self->{leagues}[$idx]->{table}->recent_goal_diff ($away);
			$game->{recent_goal_difference} = $home_diff - $away_diff;
			$game->{rgd_results} = $self->fetch_goal_difference ($goal_diff, $league_name, $game->{recent_goal_difference});
		}
	}
	return $fixtures;
}

sub do_goal_difference {
	my ($self, $fixtures, $teams) = @_;
	my ($home, $away, $home_diff, $away_diff);
	
	my $goal_diff = Football::Reports::GoalDifference->new ();
	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		my $idx = firstidx {$league_name eq $_->{title}} @{$self->{leagues}};

		for my $game (@{ $league->{games}}) {
			$home = $game->{home_team};
			$away = $game->{away_team};

			$home_diff = $self->{leagues}[$idx]->{table}->goal_diff ($home);
			$away_diff = $self->{leagues}[$idx]->{table}->goal_diff ($away);
			$game->{goal_difference} = $home_diff - $away_diff;
			$game->{gd_results} = $self->fetch_goal_difference ($goal_diff, $league_name, $game->{goal_difference});
		}
	}
	return $fixtures;
}

sub fetch_goal_difference {
	my ($self, $goal_diff_obj, $league_name, $goal_difference) = @_;
	return $goal_diff_obj->fetch_array ($league_name, $goal_difference);
}

sub do_recent_draws {
	my ($self, $fixtures) = @_;
	
	my @temp = ();
	for my $league (@$fixtures) {
		for my $game (@{ $league->{games} } ) {
			push (@temp, {
				league => $league->{league},
				game => $game,
			});
		}
	}

	return [
		sort {
			$b->{game}->{draws} <=> $a->{game}->{draws}
			or $b->{game}->{home_draws} <=> $a->{game}->{home_draws}
			or $a->{game}->{home_team} cmp $b->{game}->{home_team}
		} @temp
	];
}

sub do_favourites {
	my ($self, $year, $update) = @_;
	my $fav_path = 'C:/Mine/perl/Football/data/favourites/';

	my $fav_model = Football::Favourites_Model->new (update => $update, filename => 'uk');
	my $data_model = Football::Favourites_Data_Model->new ();

	my $iterator = each_array ( @league_names, @csv_leagues );
	while ( my ($league, $csv_league) = $iterator->() ) {
		my $file_from = $self->{path}.$csv_league.'.csv';
		my $file_to = $fav_path.$league.'/'.$year.".csv";

		my $data = $data_model->update_current ($file_from, $csv_league);
		$data_model->write_current ($file_to, $data);
		$fav_model->update ($league, $year, $data);
	}
	return {
		data => $fav_model->hash (),
		history => $fav_model->history (),
		leagues => \@league_names,
		year => $year,
	};
}

=pod

=head1 NAME

Model.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
