package Football::BenchTest::Over_Under_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

with 'Football::BenchTest::Roles::ModelBase';

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(ou_home_away ou_last_six ou_ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0.5,0.6,0.7,0.8,0.9,1 ];
    $self->{sheetname} = 'Over Unders';
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        ou_home_away => {
            from => sub { my $self = shift; $self->home_away_game (@_) },
            wins => sub { my $self = shift; $self->home_away_win (@_) },
        },
        ou_last_six => {
            from => sub { my $self = shift; $self->last_six_game (@_) },
            wins => sub { my $self = shift; $self->last_six_win (@_) },
        },
        ou_ha_lsx => {
            from => sub { my $self = shift; $self->ha_lsx_game (@_) },
            wins => sub { my $self = shift; $self->ha_lsx_win (@_) },
        },
    };
}

sub home_away_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n;
    return 0;
}

sub home_away_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

sub last_six_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{last_six} > $n;
    return 0;
}

sub last_six_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{last_six} > $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

sub ha_lsx_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n
             && $data->{last_six} > $n;
    return 0;
}

sub ha_lsx_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n
             && $data->{last_six} > $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

=pod

=head1 NAME

Football/BenchTest/Over_Under_Model.pm

=head1 SYNOPSIS

used by backtest.pl

=head1 DESCRIPTION

Methods to test validity of results from Over_Under_Model

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
