package Football::Game_Predictions::Skellam_Dist_Model;

#	MyBessel.pm 08-14/08/17, 29/09/17
#	Football::Skellam_Dist_Model 06/10/17
#	https://stats.stackexchange.com/questions/47749/how-to-calculate-cumulative-poisson-probabilities-without-adding-each-one-if-no/47758

use Math::Round qw(nearest);
use List::Util qw(max);

use MyMath qw(power);
use MyBessel qw(calc_besseliv);

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;
	$self->{max_calc} = 10;
	$self->{min_calc} = $self->{max_calc} * -1;
}

sub calc {
	my ($self, $home_expect, $away_expect) = @_;
	my $results = {};

	unless ( $home_expect == 0 or $away_expect == 0) {
		my $constant = exp ( -1 * ($home_expect + $away_expect) );
		my $root_ratio = sqrt ($home_expect / $away_expect);
		my $harmonic_mean = sqrt ($home_expect * $away_expect);

		for my $aa ($self->{min_calc}..$self->{max_calc}) {
			my $bb = nearest (0.00001, $constant * power ($root_ratio, $aa));
			$results->{$aa} = nearest (0.0001, calc_besseliv ($aa, $bb, $harmonic_mean));
		}
	}
	$results->{home_win} = $self->get_home_win ($results);
	$results->{away_win} = $self->get_away_win ($results);
	$results->{draw} = $self->get_draw ($results);
	return $results;
}

sub get_home_win {
	my ($self, $results) = @_;
	return 0 unless defined $results->{0};

	my $total = 0;
	for my $i (1..$self->{max_calc}) {
		$total += $results->{$i};
	}
	return 1 / $total;
}

sub get_away_win {
	my ($self, $results) = @_;
	return 0 unless defined $results->{0};

	my $total = 0;
	for my $i ($self->{min_calc}..-1) {
		$total += $results->{$i};
	}
	return 1 / $total;
}

sub get_draw {
	my ($self, $results) = @_;
	return 0 unless defined $results->{0};
	return 1 / $results->{0};
}

sub schwartz_sort {
	my ($self, $games) = @_;

	return [
		map	 { $_->[0] }
		sort { $b->[1] <=> $a->[1] }
		map	 { [ $_, max (	$_->{skellam}->{home_win},
							$_->{skellam}->{draw},
							$_->{skellam}->{away_win} )
		] } @$games
	];
}

# For benchmarking only, see c:/mine/perl/football/bench/mybessel_bench.pl

sub simple_sort {
	my ($self, $games) = @_;

	return [
		sort {
			max ($b->{skellam}->{home_win}, $b->{skellam}->{draw}, $b->{skellam}->{away_win})
			<=> max ($a->{skellam}->{home_win}, $a->{skellam}->{draw}, $a->{skellam}->{away_win})
		} @$games
	];
}

sub cache_sort {
	my ($self, $games) = @_;
	my %cache;

	return [
		sort {
			($cache {$b} ||= max (
				$b->{skellam}->{home_win},
				$b->{skellam}->{draw},
				$b->{skellam}->{away_win}
			)) <=>
			($cache {$a} ||= max (
				$a->{skellam}->{home_win},
				$a->{skellam}->{draw},
				$a->{skellam}->{away_win}
			))
		} @$games
	];
}

#use MyTransform qw(schwartz);
#sub transform_sort {
#	my ($self, $games) = @_;

#	return schwartz (
#		sortfunc => sub { $b->[1] <=> $a->[1] },
#		toSort => $games,
#		weighter => max (	$_->{skellam}->{home_win},
#							$_->{skellam}->{draw},
#							$_->{skellam}->{away_win} )
#	);
#}

=pod

=head1 NAME

Skellam_Dist_Model.pm

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
