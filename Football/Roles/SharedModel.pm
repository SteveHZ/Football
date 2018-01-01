package Football::Roles::SharedModel;

#	v1.1 18-19/01/17
#	v1.2 02/04/17

use List::MoreUtils qw(firstidx);
use Football::GoalExpect_Model;

use Moo::Role;

requires 'leagues';
requires 'league_names';
requires 'csv_leagues';
requires 'fixtures_file';

sub do_home_table {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };
	
	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		my $league = $self->{league_names}[$idx];
		@$league_array[$idx]->{home_table} = @$league_array[$idx]->do_home_table ( $games->{$league} );
	}
	return $league_array;
}

sub do_away_table {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };
	
	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		my $league = $self->{league_names}[$idx];
		@$league_array[$idx]->{away_table} = @$league_array[$idx]->do_away_table ( $games->{$league} );
	}
	return $league_array;
}

sub homes {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{homes} = @$league_array[$idx]->homes ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub aways {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{aways} = @$league_array[$idx]->aways ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub last_six {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };

	for my $idx (0..$#{ $self->{csv_leagues}} ) {
		@$league_array[$idx]->{last_six} = @$league_array[$idx]->last_six ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub get_fixtures {
	my $self = shift;
	my @fixtures = ();

	open (my $fh, '<', $self->{fixtures_file}) or die ("\n\nCan't find $self->{fixtures_file}");
	while (my $line = <$fh>) {
		chomp ($line);
		my ($league, $home, $away) = split (',', $line);
		if ((my $idx = firstidx {$_ eq $league} @{ $self->{csv_leagues}} ) >= 0) {
			push (@fixtures, {
				league_idx => $idx,
				league => $self->{league_names}[$idx],
				home_team => $home,
				away_team => $away,
			});
		}
	}
	close $fh;
	return \@fixtures;
}

sub do_fixtures {
	my ($self, $fixtures, $homes, $aways, $last_six) = @_;

	my @list = ();
	my $leagues = _get_unique_leagues ($fixtures);
	for my $league (@$leagues) {
		my $league_name = %$league{league};
		my @games = sort {$a->{home_team} cmp $b->{home_team} }
					grep {$_->{league_idx} eq %{$league}{league_idx} } @$fixtures;

		for my $game (@games) {
			my $home = $game->{home_team};
			my $away = $game->{away_team};
			my $idx = $game->{league_idx};
		
			$game->{homes} = @$homes[$idx]->{homes}->{$home}->{homes};
			$game->{full_homes} = @$homes[$idx]->{homes}->{$home}->{full_homes};
			$game->{home_last_six} = @$last_six[$idx]->{last_six}->{$home}->{last_six};
			$game->{full_home_last_six} = @$last_six[$idx]->{last_six}->{$home}->{full_last_six};

			$game->{home_points} = @$homes[$idx]->{homes}->{$home}->{points};
			$game->{last_six_home_points} = @$last_six[$idx]->{last_six}->{$home}->{points};
			$game->{home_draws} = @$homes[$idx]->{homes}->{$home}->{draws};
		
			$game->{aways} = @$aways[$idx]->{aways}->{$away}->{aways};
			$game->{full_aways} = @$aways[$idx]->{aways}->{$away}->{full_aways};
			$game->{away_last_six} = @$last_six[$idx]->{last_six}->{$away}->{last_six};
			$game->{full_away_last_six} = @$last_six[$idx]->{last_six}->{$away}->{full_last_six};
			
			$game->{away_points} = @$aways[$idx]->{aways}->{$away}->{points};
			$game->{last_six_away_points} = @$last_six[$idx]->{last_six}->{$away}->{points};
			$game->{away_draws} = @$aways[$idx]->{aways}->{$away}->{draws};
			$game->{draws} = $game->{home_draws} + $game->{away_draws};
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

	my %mapped = map {$_->{league_idx} => $_->{league} } @$fixtures;
	my @array = sort { $a <=> $b } keys %mapped;
	my @sorted;

	for my $idx (@array) {
		push (@sorted, {
			league_idx => $idx,
			league => $mapped{$idx},
		});
	}
	return \@sorted;
}

sub do_goal_expect {
	my ($self, $leagues, $fixture_list) = @_;
	
	my $expect = Football::GoalExpect_Model->new ();
	my ($teams, $sorted) = $expect->update ($leagues, $fixture_list);
	return ($teams, $sorted);
}

1;
