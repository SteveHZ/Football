package Rugby::Handicap_Model;

#	Rugby::Handicap_Model 09/04/17

use Moo;
use namespace::clean;

my $path = 'C:/Mine/perl/Football/Rugby/data/';

sub BUILD {
	my ($self, $args) = @_;

	$self->{hash} = $self->setup ($args->{leagues});
}

sub setup {
	my ($self, $leagues) = @_;
	my $hash = {};

	for my $league (@$leagues) {
		my $league_name = $league->{title};
		my $league_ref = \%{ $hash->{$league_name} };

		 my $sorted = \@{ $league->{team_list} };
		for my $team (@$sorted) {
			$league_ref->{$team} = $self->setup_handicaps ();
		}
	}
	return $hash;
}

sub setup_handicaps {
	my $hash = {};
	
	for (my $margin = -50; $margin <= 50; $margin += 2) {
		$hash->{$margin} = 0;
	}
	$hash->{games} = 0;
	$hash->{won} = 0;
	$hash->{lost} = 0;
	return $hash;
}

sub update {
	my ($self, $league, $team, $win_margin) = @_;
	my $teamref = $self->{hash}->{$league}->{$team};

	if ($win_margin > 0) {
		for (my $margin = 2; $margin <= $win_margin; $margin += 2) {
			$teamref->{$margin} ++;
		}
		$teamref->{won} ++;
	} else {
		for (my $margin = -2; $margin >= $win_margin; $margin -= 2) {
			$teamref->{$margin} ++;
		}
		$teamref->{lost} ++;
	}
	$teamref->{games} ++;
}

sub fetch_hash {
	my ($self, $league, $team) = @_;
	return \%{ $self->{hash}->{$league}->{$team} };
}

1;
