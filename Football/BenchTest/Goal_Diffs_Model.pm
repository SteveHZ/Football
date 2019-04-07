package Football::BenchTest::Goal_Diffs_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

with 'Football::BenchTest::Roles::ModelBase';

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(gd_home_away gd_last_six gd_ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0,0.5,1,1.5,2,2.5,3 ];
    $self->{sheetname} = 'Goal Diffs';
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        gd_home_away => {
            from => sub { my $self = shift; $self->home_away_game (@_) },
            wins => sub { my $self = shift; $self->home_away_win (@_) },
        },
        gd_last_six => {
            from => sub { my $self = shift; $self->last_six_game (@_) },
            wins => sub { my $self = shift; $self->last_six_win (@_) },
        },
        gd_ha_lsx => {
            from => sub { my $self = shift; $self->ha_lsx_game (@_) },
            wins => sub { my $self = shift; $self->ha_lsx_win (@_) },
        },
    };
}

sub home_away_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if abs ( $data->{home_away_goal_diff} ) > $n;
    return 0;
}

sub home_away_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if ($data->{home_score} > $data->{away_score} && $data->{home_away_goal_diff} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{home_away_goal_diff} < ($n * -1));
    return 0;
}

sub last_six_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if abs( $data->{last_six_goal_diff} ) > $n;
    return 0;
}

sub last_six_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if ($data->{home_score} > $data->{away_score} && $data->{last_six_goal_diff} > $n )
    or ($data->{away_score} > $data->{home_score} && $data->{last_six_goal_diff} < ($n * -1) );
    return 0;
}

sub ha_lsx_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if abs ( $data->{home_away_goal_diff} ) > $n
             && abs ( $data->{last_six_goal_diff} ) > $n;
    return 0;
}

sub ha_lsx_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if (($data->{home_score} > $data->{away_score} && $data->{home_away_goal_diff} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{home_away_goal_diff} < ($n * -1) ))
        &&
            (($data->{home_score} > $data->{away_score} && $data->{last_six_goal_diff} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{last_six_goal_diff} < ($n * -1) ));
    return 0;
}

=pod

=head1 NAME

Football/BenchTest/Goal_Diffs_Model.pm

=head1 SYNOPSIS

used by backtest.pl

=head1 DESCRIPTION

Methods to test validity of results from Goal_Diffs_Model

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
