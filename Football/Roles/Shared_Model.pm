package Football::Roles::Shared_Model;

#	v1.1 18-19/01/17
#	v1.2 02/04/17

use List::MoreUtils qw(firstidx);
#use Football::Game_Prediction_Models;
use Football::Globals qw($default_stats_size );

use Moo::Role;

requires qw( leagues league_names csv_leagues );

sub do_home_table {
	my ($self, $games) = @_;
	my $league_array = \@{ $self->{leagues} };
	
	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		my $league = $self->{league_names}[$idx];
		@$league_array[$idx]->{home_table} = @$league_array[$idx]->do_home_table ( $games->{$league} );
	}
	return $league_array;
}

sub do_away_table {
	my ($self, $games) = @_;
	my $league_array = \@{ $self->{leagues} };
	
	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		my $league = $self->{league_names}[$idx];
		@$league_array[$idx]->{away_table} = @$league_array[$idx]->do_away_table ( $games->{$league} );
	}
	return $league_array;
}

sub homes {
	my ($self, $games) = @_;
	my $league_array = \@{ $self->{leagues} };

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{homes} = @$league_array[$idx]->homes ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub aways {
	my ($self, $games) = @_;
	my $league_array = \@{ $self->{leagues} };

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{aways} = @$league_array[$idx]->aways ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub last_six {
	my ($self, $games) = @_;
	my $league_array = \@{ $self->{leagues} };

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{last_six} = @$league_array[$idx]->last_six ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

=head
sub do_fixtures {
	my ($self, $fixture_list, $homes, $aways, $last_six) = @_;
	my $stat_size = $default_stats_size * 2;

	my @list = ();
	my $leagues = _get_unique_leagues ($fixture_list);
	for my $league (@$leagues) {
		my $league_name = %$league{league};
		my @games = sort {$a->{home_team} cmp $b->{home_team} }
					grep {$_->{league_idx} eq %{$league}{league_idx} } @$fixture_list;

		for my $game (@games) {
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

			$game->{home_away} = ($game->{home_over_under} + $game->{away_over_under}) / $stat_size,
			$game->{last_six} = ($game->{home_last_six_over_under} + $game->{away_last_six_over_under}) / $stat_size,

		}
		push (@list, {
			league => $league_name,
			games => \@games,
		});
	}
	return \@list;
}

sub _get_unique_leagues {
	my $fixtures = shift;

#	map unique values of league_idx
	my %leagues = map { $_->{league_idx} => $_->{league} } @$fixtures;

#	map to sorted array of hashrefs
	return [ 
		map { {
			'league_idx' => $_,
			'league' => $leagues{$_},
		} } 
		sort { $a <=> $b } keys %leagues
	];
}

#	wrapper for testing
sub get_unique_leagues {
	my ($self, $fixtures) = @_;
	return _get_unique_leagues ($fixtures);
}

sub do_predict_models {
	my ($self, $leagues, $fixture_list, $fixtures, $sport) = @_;
	my $predict_model = Football::Game_Prediction_Models->new ();

	my ($teams, $sorted) = $predict_model->calc_goal_expect ($leagues, $fixture_list);
	$sorted->{match_odds} = $predict_model->calc_match_odds ($fixture_list);# unless $sport eq "Rugby";
	$sorted->{skellam} = $predict_model->calc_skellam_dist ($fixture_list);# unless $sport eq "Rugby";
	$sorted->{over_under} = $predict_model->calc_over_under ($fixture_list);
	
	return ($teams, $sorted);
}
=cut

1;
