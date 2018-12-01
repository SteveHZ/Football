package Football::Roles::Shared_Model;

#	v1.1 18-19/01/17
#	v1.2 02/04/17

use Clone qw(clone);

use Football::Game_Prediction_Models;
use Football::Globals qw($default_stats_size );
use MyKeyword qw(TESTING); # for model.t

use Moo::Role;

requires qw( read_json update leagues league_names csv_leagues test_season_data );

sub BUILD {}

after 'BUILD' => sub {
	my $self = shift;
	$self->{league_idx} = $self->build_league_idx ($self->{league_names});
};

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

sub homes {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{homes} = @$league_array[$idx]->homes ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub aways {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{aways} = @$league_array[$idx]->aways ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub last_six {
	my ($self, $games) = @_;
	my $league_array = $self->{leagues};

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{last_six} = @$league_array[$idx]->last_six ( @$league_array[$idx]->{teams} );
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
	my $datafunc = _get_game_data_func ($homes, $aways, $last_six);
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

sub _get_game_data_func {
	my ($homes, $aways, $last_six) = @_;
	my $stat_size = $default_stats_size * 2;

	return sub {
		my $game = shift;
		my $home = $game->{home_team};
		my $away = $game->{away_team};
		my $idx = $game->{league_idx};

		$game->{homes} = @$homes[$idx]->{homes}->{$home}->{homes};
		$game->{full_homes} = @$homes[$idx]->{homes}->{$home}->{full_homes};
		$game->{home_last_six} = @$last_six[$idx]->{last_six}->{$home}->{last_six};
		$game->{full_home_last_six} = @$last_six[$idx]->{last_six}->{$home}->{full_last_six};
		$game->{home_over_under} = @$homes[$idx]->{homes}->{$home}->{home_over_under};

		$game->{home_points} = @$homes[$idx]->{homes}->{$home}->{points};
		$game->{home_draws} = @$homes[$idx]->{homes}->{$home}->{draws};
		$game->{last_six_home_points} = @$last_six[$idx]->{last_six}->{$home}->{points};
		$game->{home_last_six_over_under} = @$homes[$idx]->{last_six}->{$home}->{last_six_over_under};

		$game->{aways} = @$aways[$idx]->{aways}->{$away}->{aways};
		$game->{full_aways} = @$aways[$idx]->{aways}->{$away}->{full_aways};
		$game->{away_last_six} = @$last_six[$idx]->{last_six}->{$away}->{last_six};
		$game->{full_away_last_six} = @$last_six[$idx]->{last_six}->{$away}->{full_last_six};
		$game->{away_over_under} = @$aways[$idx]->{aways}->{$away}->{away_over_under};

		$game->{away_points} = @$aways[$idx]->{aways}->{$away}->{points};
		$game->{away_draws} = @$aways[$idx]->{aways}->{$away}->{draws};
		$game->{last_six_away_points} = @$last_six[$idx]->{last_six}->{$away}->{points};
		$game->{away_last_six_over_under} = @$aways[$idx]->{last_six}->{$away}->{last_six_over_under};
		$game->{draws} = $game->{home_draws} + $game->{away_draws};

		$game->{home_away} = ($game->{home_over_under} + $game->{away_over_under}) / $stat_size;
		$game->{last_six} = ($game->{home_last_six_over_under} + $game->{away_last_six_over_under}) / $stat_size;
	};
}

1;
