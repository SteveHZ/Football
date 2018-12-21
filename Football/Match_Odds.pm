package Football::Match_Odds;

#	Football::Match_Odds.pm 02-03/07/17

use Math::Round qw(nearest);
use List::Util qw(min);
use Football::MyPoisson;

use Moo;
use namespace::clean;

sub BUILD {
	my ($self, $args) = @_;

	$self->{max} = $args->{max};
	$self->{max} //= 5;
	$self->{stats} = ( [] );
}

sub calc {
	my ($self, $home_expect, $away_expect) = @_;
	my $p = Football::MyPoisson->new ();
	my %cache_p;

	for my $home_score (0..$self->{max}) {
		my $home_p = $p->poisson ($home_expect, $home_score);
		for my $away_score (0..$self->{max}) {
			unless (exists $cache_p{$away_score}) {
				$cache_p{$away_score} = $p->poisson ($away_expect, $away_score);
			}
			$self->{stats}[$home_score][$away_score] = $p->poisson_game ($home_p, $cache_p{$away_score});
		}
	}
	return $self->{stats};
}

sub schwartz_sort {
	my ($self, $games) = @_;

	return [
		map	 { $_->[0] }
		sort { $a->[1] <=> $b->[1] }
		map	 { [
			$_, min ( $_->{home_win},
					  $_->{away_win} )
		] } @$games
	];
}

sub print_all {
	my $self = shift;
	for my $home_score (0..$self->{max}) {
		for my $away_score (0..$self->{max}) {
			print "\n$home_score - $away_score = ".
			$self->{stats}[$home_score][$away_score];
		}
	}
}

sub home_win {
	my $self = shift;
	my $total = 0;

	for my $home_score (1..$self->{max}) {
		for my $away_score (0..$home_score - 1) {
			$total += $self->{stats}[$home_score][$away_score];
		}
	}
	return nearest (0.01, $total);
}

sub home_win_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->home_win () ) == 0;
	return nearest (0.01, 100 / $stats);
}

sub away_win {
	my $self = shift;
	my $total = 0;

	for my $away_score (1..$self->{max}) {
		for my $home_score (0..$away_score - 1) {
			$total += $self->{stats}[$home_score][$away_score];
		}
	}
	return nearest (0.01, $total);
}

sub away_win_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->away_win () ) == 0;
	return nearest (0.01, 100 / $stats);
}

sub draw {
	my $self = shift;
	my $total = 0;

	for my $score (0..$self->{max}) {
		$total += $self->{stats}[$score][$score];
	}
	return nearest (0.01, $total);
}

sub draw_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->draw () ) == 0;
	return nearest (0.01, 100 / $stats);
}

sub both_sides_yes {
	my $self = shift;
	my $total = 0;

	for my $home_score (1..$self->{max}) {
		for my $away_score (1..$self->{max}) {
			$total += $self->{stats}[$home_score][$away_score];
		}
	}
	return nearest (0.01, $total);
}

sub both_sides_yes_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->both_sides_yes () ) == 0;
	return nearest (0.01, 100 / $stats);
}

sub both_sides_no {
	my $self = shift;
	my $total = 0;

	$total += $self->{stats}[0][0];
	for my $score (1..$self->{max}) {
		$total += $self->{stats}[$score][0];
		$total += $self->{stats}[0][$score];
	}
	return nearest (0.01, $total);
}

sub both_sides_no_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->both_sides_no () ) == 0;
	return nearest (0.01, 100 / $stats);
}

sub under_2pt5 {
	my $self = shift;
	my $total = 0;

	for my $home_score (0..2) {
		for my $away_score (0..2) {
			if (($home_score + $away_score) < 3) {
				$total += $self->{stats}[$home_score][$away_score];
			}
		}
	}
	return nearest (0.01, $total);
}

sub under_2pt5_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->under_2pt5 () ) == 0;
	return nearest (0.01, 100 / $stats);
}

sub over_2pt5 {
	my $self = shift;
	my $total = 0;

	for my $home_score (0..$self->{max}) {
		for my $away_score (0..$self->{max}) {
			if ($home_score + $away_score > 2) {
				$total += $self->{stats}[$home_score][$away_score];
			}
		}
	}
	return nearest (0.01, $total);
}

sub over_2pt5_odds {
	my $self = shift;

	return 0 if ( my $stats = $self->over_2pt5 () ) == 0;
	return nearest (0.01, 100 / $stats);
}

=pod

=head1 NAME

Match_Odds.pm

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
