package Football::BenchTest::Goal_Expect_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

with 'Football::BenchTest::Roles::ModelBase';

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(home_away last_six ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5 ];
    $self->{sheetname} = 'Goal Expects';
}

sub _build_dispatch {
    my $self = shift;

    $self->{dispatch} = {
        home_away => {
            from => sub { my $self = shift; $self->home_away_game (@_) },
            wins => sub { my $self = shift; $self->home_away_win (@_) },
        },
        last_six => {
            from => sub { my $self = shift; $self->last_six_game (@_) },
            wins => sub { my $self = shift; $self->last_six_win (@_) },
        },
        ha_lsx => {
            from => sub { my $self = shift; $self->ha_lsx_game (@_) },
            wins => sub { my $self = shift; $self->ha_lsx_win (@_) },
        },
    };
}

sub home_away_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if abs $data->{expected_goal_diff} > $n;
    return 0;
}

sub home_away_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if ($data->{home_score} > $data->{away_score} && $data->{expected_goal_diff} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{expected_goal_diff} < ($n * -1));
    return 0;
}

sub last_six_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if abs $data->{expected_goal_diff_last_six} > $n;
    return 0;
}

sub last_six_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if ($data->{home_score} > $data->{away_score} && $data->{expected_goal_diff_last_six} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{expected_goal_diff_last_six} < ($n * -1) );
    return 0;
}

sub ha_lsx_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if abs $data->{expected_goal_diff} > $n
             && abs $data->{expected_goal_diff_last_six} > $n;
    return 0;
}

sub ha_lsx_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if (($data->{home_score} > $data->{away_score} && $data->{expected_goal_diff} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{expected_goal_diff} < ($n * -1) ))
        &&
            (($data->{home_score} > $data->{away_score} && $data->{expected_goal_diff_last_six} > $n )
             or ($data->{away_score} > $data->{home_score} && $data->{expected_goal_diff_last_six} < ($n * -1) ));
    return 0;
}

=pod

=head1 NAME

Football/BenchTest/Goal_Expect_Model.pm

=head1 SYNOPSIS

used by backtest.pl

=head1 DESCRIPTION

Methods to test validity of results from Goal_Expect_Model

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
