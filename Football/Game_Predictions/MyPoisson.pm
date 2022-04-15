package Football::Game_Predictions::MyPoisson;

#	Football::MyPoisson.pm 02-05/07/17, 18/08/17
#	pure perl version

use Math::Round qw(nearest);
use MyMath qw(power factorial);

use Moo;
use namespace::clean;

has 'max' => (is => 'ro', default => 5);
has 'stats' => (is => 'rw');

sub BUILD {
	my $self = shift;
#	$self->{stats} = [];
	$self->{euler} = 2.71828;
}

sub poisson_result {
	my ($self, $home, $away) = @_;
	return nearest (0.001, $home * $away * 100);
}

sub poisson {
	my ($self, $expect, $score) = @_;
	return	power ($expect, $score) *
	 		power ($self->{euler}, $expect * -1) /
			factorial ($score);
}

# API for testing

sub calc_game {
	my ($self, $home_expect, $away_expect) = @_;
	my %cache_p;

	for my $home_score (0..$self->{max}) {
		my $home_p = $self->poisson ($home_expect, $home_score);
		for my $away_score (0..$self->{max}) {
			unless (exists $cache_p{$away_score}) {
				$cache_p{$away_score} = $self->poisson ($away_expect, $away_score);
			}
			$self->{stats}[$home_score][$away_score] = $self->poisson_result ($home_p, $cache_p{$away_score});
		}
	}
	return $self->{stats};
}

=begin comment

$self->{weighted} = [ 1.05,0.99,0.99,0.99,0.99,0.99,0.98,0.96,0.95,0.95,0.95 ];

sub poisson_weighted {
	my ($self, $expect, $score) = @_;
	return	$self->poisson ($expect, $score) *
			$self->{weighted}->[$score];
}

sub get_calc_func {
	my ($self, $weighted) = @_;
	return ($weighted == 0)
		? sub { my $self = shift; $self->poisson (@_); }
		: sub { my $self = shift; $self->poisson_weighted (@_); };
}

=end comment
=cut

=pod

=head1 NAME

MyPoisson.pm

=head1 SYNOPSIS

Use by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
