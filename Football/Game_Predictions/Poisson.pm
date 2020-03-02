package Football::Game_Predictions::Poisson;

#	Football::MyPoisson.pm 02-05/07/17, 18/08/17, 02/03/20

use MyHeader;
use Math::Round qw(nearest);
use MyMath qw(power factorial);
use Math::CDF qw(ppois);

use Moo;
use namespace::clean;

has 'max' => (is => 'ro', default => 5);
has 'weighted' => (is => 'ro', default => 0);

sub BUILD {
	my $self = shift;
	$self->{euler} = 2.71828;
	$self->{weights} = [ 1.05,0.99,0.99,0.99,0.99,0.99,0.98,0.96,0.95,0.95,0.95 ];

    $self->{home_cache} = {};
    $self->{away_cache} = {};
    $self->{stats} = [];
}

sub calc_poisson {
    my ($self, $home_expect, $away_expect) = @_;

    for my $home_score (0..$self->{max}) {
        my $home_p = $self->calc_home ($home_score, $home_expect);
        for my $away_score (0..$self->{max}) {
            my $away_p = $self->calc_away ($away_score, $away_expect);
            $self->{stats}->[$home_score][$away_score] = nearest (0.001, $home_p * $away_p * 100);
        }
    }
    return $self->{stats};
}

sub calc_home {
    my ($self, $home_score, $home_expect) = @_;
    $self->{home_cache}->{$home_score} = ppois ($home_score, $home_expect);
    my $temp = ($home_score == 0)   ? $self->{home_cache}->{$home_score}
                                    : $self->{home_cache}->{$home_score} - $self->{home_cache}->{$home_score - 1};
    return ($self->{weighted} == 0) ? $temp
                                    : $temp * $self->{weights}[$home_score];
}

sub calc_away {
    my ($self, $away_score, $away_expect) = @_;
    unless (exists $self->{away_cache}->{$away_score}) {
        $self->{away_cache}->{$away_score} = ppois ($away_score, $away_expect);
    }
    my $temp = ($away_score == 0)   ? $self->{away_cache}->{$away_score}
                                    : $self->{away_cache}->{$away_score} - $self->{away_cache}->{$away_score - 1};
    return ($self->{weighted} == 0) ? $temp
                                    : $temp * $self->{weights}[$away_score];
}

=cut

=pod

=head1 NAME

Poisson.pm

=head1 SYNOPSIS

Use by predict.pl

=head1 DESCRIPTION

Uses Math::CDF::pois routine

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
