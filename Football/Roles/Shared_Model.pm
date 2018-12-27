package Football::Roles::Shared_Model;

#	v1.1 18-19/01/17 v1.2 02/04/17
#	v1.3 01/12/18

use Clone qw(clone);

use Football::Game_Prediction_Models;
use Football::Globals qw($default_stats_size );
use MyKeyword qw(TESTING); # for model.t

use Moo::Role;

requires qw( read_json update leagues league_names csv_leagues test_season_data );

sub build_league_idx {
	my ($self, $leagues) = @_;
	my $idx = 0;
	return {
		map { $_ => $idx++ } @$leagues
	};
}

sub get_league_idx {
	my ($self, $league) = @_;
	return $self->{league_idx}->{$league};
}

sub read_games {
	my ($self, $update) = @_;
	my $games;

	TESTING {
		print "    Reading test data from $self->{test_season_data}\n";
		$games = $self->read_json ($self->{test_season_data});
	} elsif ($update) {
		$games = $self->update ();
	} else {
		$games = (-e $self->{season_data}) ?
			$self->read_json ($self->{season_data}) : {};
	}
	return $games;
}

sub do_home_table {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		my $league = $self->{league_names}[$idx];
		@$league_array[$idx]->{home_table} = @$league_array[$idx]->do_home_table ( $games->{$league} );
	}
	return $league_array;
}

sub do_away_table {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		my $league = $self->{league_names}[$idx];
		@$league_array[$idx]->{away_table} = @$league_array[$idx]->do_away_table ( $games->{$league} );
	}
	return $league_array;
}

sub do_homes {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{homes} = @$league_array[$idx]->do_homes ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub do_aways {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{aways} = @$league_array[$idx]->do_aways ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub do_last_six {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{last_six} = @$league_array[$idx]->do_last_six ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub _get_unique_leagues {
	my $fixtures = shift;

#	map unique values of league_idx
	my %leagues = map { $_->{league_idx} => $_->{league} } @$fixtures;

#	map to sorted array of hashrefs
	return [
		map { {
			'league_idx' => $_,
			'league_name' => $leagues{$_},
		} }
		sort { $a <=> $b } keys %leagues
	];
}

#	wrapper for testing
sub get_unique_leagues {
	TESTNG { # shift $self from @_first
		shift;	return _get_unique_leagues (shift);
	}
}

sub do_predict_models {
	my ($self, $fixtures, $leagues) = @_;
	my $predict_model = Football::Game_Prediction_Models->new ();

	my ($teams, $sorted) = $predict_model->calc_goal_expect ($fixtures, $leagues);
	$sorted->{match_odds} = $predict_model->calc_match_odds ($fixtures);
	$sorted->{skellam} = $predict_model->calc_skellam_dist ($fixtures);
	$sorted->{over_under} = $predict_model->calc_over_under ($fixtures, $leagues);

	return ($teams, $sorted);
}

sub do_fixtures {
	my ($self, $fixtures, $homes, $aways, $last_six) = @_;

	my $leagues = $self->get_unique_leagues ($fixtures);
	my $datafunc = $self->get_game_data_func ($homes, $aways, $last_six);
	my $fixtures_clone = clone $fixtures;
	my @fixture_list = ();

	for my $league (@$leagues) {
		my @games = sort { $a->{home_team} cmp $b->{home_team} }
					grep { $_->{league_idx} eq $league->{league_idx} }
					@$fixtures_clone;

		$datafunc->($_) for @games;
		push @fixture_list, {
			league 	=> $league->{league_name},
			games  	=> \@games,
		};
	}
	return {
		by_match  =>  $fixtures_clone,
		by_league => \@fixture_list,
	};
}

sub get_game_data_func {
	my ($self, $homes, $aways, $last_six) = @_;
	my $stat_size = $default_stats_size * 2;

	return sub {
		my $game = shift;
		my $home = $game->{home_team};
		my $away = $game->{away_team};
		my $league = @{ $self->{leagues} }[$game->{league_idx}];

		$game->{homes} = $league->get_homes ($home);
		$game->{full_homes} = $league->get_full_homes ($home);
		$game->{home_points} = $league->get_home_points ($home);
		$game->{home_draws} = $league->get_home_draws ($home);
		$game->{home_over_under} = $league->get_home_over_under ($home);

		$game->{home_last_six} = $league->get_last_six ($home);
		$game->{full_home_last_six} = $league->get_full_last_six ($home);
		$game->{last_six_home_points} = $league->get_last_six_points ($home);
		$game->{home_last_six_over_under} = $league->get_last_six_over_under ($home);

		$game->{aways} = $league->get_aways ($away);
		$game->{full_aways} = $league->get_full_aways ($away);
		$game->{away_points} = $league->get_away_points ($away);
		$game->{away_draws} = $league->get_away_draws ($away);
		$game->{away_over_under} = $league->get_away_over_under ($away);

		$game->{away_last_six} = $league->get_last_six ($away);
		$game->{full_away_last_six} = $league->get_full_last_six ($away);
		$game->{last_six_away_points} = $league->get_last_six_points ($away);
		$game->{away_last_six_over_under} = $league->get_last_six_over_under ($away);

		$game->{draws} = $game->{home_draws} + $game->{away_draws};
		$game->{home_away} = ($game->{home_over_under} + $game->{away_over_under}) / $stat_size;
		$game->{last_six} = ($game->{home_last_six_over_under} + $game->{away_last_six_over_under}) / $stat_size;
	};
}

1;
