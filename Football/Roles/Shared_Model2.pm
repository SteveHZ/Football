package Football::Roles::Shared_Model2;

#	v1.1 18-19/01/17
#	v1.2 02/04/17

use List::MoreUtils qw(firstidx);
use Football::Game_Prediction_Models;
use Football::Globals qw($default_stats_size );

use Moo::Role;

requires qw( leagues league_names csv_leagues );

sub do_fixtures2 {
	my ($self, $fixtures, $homes, $aways, $last_six) = @_;

	my $datafunc = _get_game_data ($homes, $aways, $last_six);
	my $leagues = $self->get_unique_leagues ($fixtures);
	my @list = ();

	for my $league (@$leagues) {
		my $league_name = %$league{league};

		my @games = sort {$a->{home_team} cmp $b->{home_team} }
					grep {$_->{league_idx} eq %{$league}{league_idx} }
					@$fixtures;

		$datafunc->($_) for @games;
		push (@list, {
			league => $league_name,
			games => \@games,
		});
	}
	return \@list;
}

sub _get_game_data {
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

=head

sub _get_game_data {
	my ($homes, $aways, $last_six) = @_;
	my $stat_size = $default_stats_size * 2;
	
	return sub {
		my $game = shift;
		my $home = $game->{home_team};
		my $away = $game->{away_team};
		my $idx = $game->{league_idx};

		my $home_draws = @$homes[$idx]->{homes}->{$home}->{draws};
		my $away_draws = @$aways[$idx]->{aways}->{$away}->{draws};
		my $home_over_under = @$homes[$idx]->{homes}->{$home}->{home_over_under};
		my $away_over_under = @$aways[$idx]->{aways}->{$away}->{away_over_under};
		my $home_last_six_over_under = @$homes[$idx]->{last_six}->{$home}->{last_six_over_under};
		my $away_last_six_over_under = @$aways[$idx]->{last_six}->{$away}->{last_six_over_under};

		return {
			league_idx => $game->{league_idx},
			league => $game->{league},
			home_team => $game->{home_team},
			away_team => $game->{away_team},
			date => $game->{date},

			homes => @$homes[$idx]->{homes}->{$home}->{homes},
			full_homes => @$homes[$idx]->{homes}->{$home}->{full_homes},
			home_last_six => @$last_six[$idx]->{last_six}->{$home}->{last_six},
			full_home_last_six => @$last_six[$idx]->{last_six}->{$home}->{full_last_six},
			home_over_under => $home_over_under,
#			home_over_under => @$homes[$idx]->{homes}->{$home}->{home_over_under},

			home_points => @$homes[$idx]->{homes}->{$home}->{points},
			home_draws => $home_draws,
#			home_draws => @$homes[$idx]->{homes}->{$home}->{draws},
			last_six_home_points => @$last_six[$idx]->{last_six}->{$home}->{points},
			home_last_six_over_under => $home_last_six_over_under,
#			home_last_six_over_under => @$homes[$idx]->{last_six}->{$home}->{last_six_over_under},
		
			aways => @$aways[$idx]->{aways}->{$away}->{aways},
			full_aways => @$aways[$idx]->{aways}->{$away}->{full_aways},
			away_last_six => @$last_six[$idx]->{last_six}->{$away}->{last_six},
			full_away_last_six => @$last_six[$idx]->{last_six}->{$away}->{full_last_six},
			away_over_under => $away_over_under,
#			away_over_under => @$aways[$idx]->{aways}->{$away}->{away_over_under},
			
			away_points => @$aways[$idx]->{aways}->{$away}->{points},
			away_draws => $away_draws,
#			away_draws => @$aways[$idx]->{aways}->{$away}->{draws},
			last_six_away_points => @$last_six[$idx]->{last_six}->{$away}->{points},
			away_last_six_over_under => $away_last_six_over_under,
#			away_last_six_over_under => @$aways[$idx]->{last_six}->{$away}->{last_six_over_under},
			draws => $home_draws + $away_draws,

			home_away => ($home_over_under + $away_over_under) / $stat_size,
			last_six => ($home_last_six_over_under + $away_last_six_over_under) / $stat_size,
		};
	};
}
=cut
1;
