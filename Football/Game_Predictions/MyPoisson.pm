package Football::Game_Predictions::MyPoisson;

#	Football::MyPoisson.pm 02-05/07/17, 18/08/17

use Math::Round qw(nearest);
use MyMath qw(power factorial);

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;
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
