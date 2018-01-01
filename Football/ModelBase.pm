package Football::ModelBase;

use Moo;
use namespace::clean;

use List::MoreUtils qw(firstidx);

my @leagues = (	"Premier League", "Championship", "League One", "League Two", "Conference",
				"Scots Premier", "Scots Championship", "Scots League One", "Scots League Two",
);
my @csv_leagues = qw(E0 E1 E2 E3 EC SC0 SC1 SC2 SC3);

sub do_home_table {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };
	
	for my $idx (0..$#csv_leagues) {
		@$league_array[$idx]->{home_table} = @$league_array[$idx]->do_home_table ($games->{ $leagues[$idx] });
	}
	return $league_array;
}

sub do_away_table {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };
	
	for my $idx (0..$#csv_leagues) {
		@$league_array[$idx]->{away_table} = @$league_array[$idx]->do_away_table ($games->{ $leagues[$idx] });
	}
	return $league_array;
}

sub homes {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };

	for my $idx (0..$#csv_leagues) {
		@$league_array[$idx]->{homes} = @$league_array[$idx]->homes (@$league_array[$idx]->{teams});
	}
	return $league_array;
}

sub aways {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };

	for my $idx (0..$#csv_leagues) {
		@$league_array[$idx]->{aways} = @$league_array[$idx]->aways (@$league_array[$idx]->{teams});
	}
	return $league_array;
}

sub last_six {
	my ($self, $games) = @_;
	my $league_array = \@ { $self->{leagues} };

	for my $idx (0..$#csv_leagues) {
		@$league_array[$idx]->{last_six} = @$league_array[$idx]->last_six (@$league_array[$idx]->{teams});
	}
	return $league_array;
}

sub get_fixtures {
	my ($self, $fixtures_file) = @_;
	
	my ($league, $home, $away, $idx);
	my @fixtures = ();

	open (my $fh, '<', $fixtures_file) or die ("Can't find $fixtures_file");
	while (my $line = <$fh>) {
		chomp ($line);
		($league, $home, $away) = split (',', $line);
		if (($idx = firstidx {$_ eq $league} @csv_leagues) >= 0) {
			push (@fixtures, {
				idx => $idx,
				league => $leagues[$idx],
				home_team => $home,
				away_team => $away,
			});
		}
	}
	close $fh;
	return \@fixtures;
}

sub do_fixtures {
	my ($self, $fixtures, $homes, $aways) = @_;

	my @list = ();
	my $leagues = _get_unique_leagues ($fixtures);
	for my $league (@$leagues) {
		my $league_name = %$league{league};
		my @games = sort {$a->{home_team} cmp $b->{home_team} }
					grep {$_->{idx} eq %{$league}{idx} } @$fixtures;

		for my $game (@games) {
			my $home = $game->{home_team};
			my $away = $game->{away_team};
			my $idx = $game->{idx};
		
			$game->{homes} = @$homes[$idx]->{homes}->{$home}->{homes};
			$game->{full_homes} = @$homes[$idx]->{homes}->{$home}->{full_homes};
			$game->{home_points} = @$homes[$idx]->{homes}->{$home}->{points};
			$game->{home_draws} = @$homes[$idx]->{homes}->{$home}->{draws};
		
			$game->{aways} = @$aways[$idx]->{aways}->{$away}->{aways};
			$game->{full_aways} = @$aways[$idx]->{aways}->{$away}->{full_aways};
			$game->{away_points} = @$aways[$idx]->{aways}->{$away}->{points};
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

	my %mapped = map {$_->{idx} => $_->{league} } @$fixtures;
	my @array = sort { $a <=> $b } keys %mapped;
	my @sorted;

	for my $idx (@array) {
		push (@sorted, {
			idx => $idx,
			league => $mapped{$idx},
		});
	}
	return \@sorted;
}

1;
