package Football::Roles::Shared_Model;

#	v1.1 18-19/01/17 v1.2 02/04/17
#	v1.3 01/12/18

use Storable qw(dclone);

use Football::Football_Data_Model;
use Football::Globals qw( $default_stats_size );
use MyKeyword qw(TESTING ANALYSIS); # for model.t
use MyJSON qw(read_json);

use Moo::Role;

requires qw( leagues league_names csv_leagues season_data test_season_data );

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
	$update //= 0;
	my $games;

	TESTING {
		print "*** Reading test data from \$self->test_season_data\n\n";
		$games = $self->read_json ($self->test_season_data);
	} elsif ($update) {
		$games = $self->update ();
	} else {
		$games = (-e $self->season_data) ?
			$self->read_json ($self->season_data) : {};
	}
	return $games;
}

sub do_homes {
	my ($self, $games) = @_;
	my $league_array = $self->leagues;

	for my $idx (0..$#{ $self->csv_leagues } ) {
		@$league_array[$idx]->{homes} = @$league_array[$idx]->do_homes ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub do_aways {
	my ($self, $games) = @_;
	my $league_array = $self->leagues;

	for my $idx (0..$#{ $self->csv_leagues } ) {
		@$league_array[$idx]->{aways} = @$league_array[$idx]->do_aways ( @$league_array[$idx]->{teams} );
	}
	return $league_array;
}

sub do_last_six {
	my ($self, $games) = @_;
	my $league_array = $self->leagues;

	for my $idx (0..$#{ $self->csv_leagues } ) {
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
			league_idx => $_,
			league_name => $leagues{$_},
		} }
		sort { $a <=> $b } keys %leagues
	];
}

#	wrapper for testing
sub get_unique_leagues {
	TESTNG {
		shift; # shift $self from @_ first
		return _get_unique_leagues (shift);
	}
}

sub do_fixtures {
	my ($self, $fixtures) = @_;

	my $leagues = $self->get_unique_leagues ($fixtures);
	my $datafunc = $self->get_game_data_func ();
	my $fixtures_clone = dclone $fixtures;
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
	my $self = shift;
	my $stat_size = $default_stats_size * 2;

	return sub {
		my ($game, $league) = @_;
		$league //= $self->{leagues}->[ $game->{league_idx} ];

		my $home = $game->{home_team};
		my $away = $game->{away_team};

		$game->{homes} = $league->get_homes ($home);
		$game->{full_homes} = $league->get_full_homes ($home);
		$game->{home_points} = $league->get_home_points ($home);
		$game->{home_draws} = $league->get_home_draws ($home);

		$game->{home_last_six} = $league->get_last_six ($home);
		$game->{full_home_last_six} = $league->get_full_last_six ($home);
		$game->{last_six_home_points} = $league->get_last_six_points ($home);

		$game->{aways} = $league->get_aways ($away);
		$game->{full_aways} = $league->get_full_aways ($away);
		$game->{away_points} = $league->get_away_points ($away);
		$game->{away_draws} = $league->get_away_draws ($away);

		$game->{away_last_six} = $league->get_last_six ($away);
		$game->{full_away_last_six} = $league->get_full_last_six ($away);
		$game->{last_six_away_points} = $league->get_last_six_points ($away);

		$game->{draws} = $game->{home_draws} + $game->{away_draws};
	};
}

# Iterate each league in stats->{by_league} returned from Football::Model::do_fixtures
sub iterate_stats_by_league {
    my ($self, $stats) = @_;
    my $size = scalar $stats->{by_league}->@*;
    my $index = 0;

    return sub {
        return undef if $index == $size;
		return $stats->{by_league}->[$index ++];
    }
}

=pod

=head1 NAME

Football::Roles::Shared_Model.pm

=head1 SYNOPSIS

Role used by Model.pm to factor out routines common to both Football and Rugby models.

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
