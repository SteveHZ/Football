package Football::BenchTest::OU_Points2_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

with 'Football::BenchTest::Roles::ModelBase';
has 'over_range' => (is =>'ro');
has 'under_range' => (is =>'ro');

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(ou_overs ou_unders) ];
    $self->{headings} = ['Overs', 'Unders'];
    $self->{range} = [ 0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5 ];
    $self->{over_range} = [ 2.5,3,3.5,4,4.5,5 ];
    $self->{under_range} = [ 0,0.5,1,1.5,2 ];
    $self->{sheetname} = 'OU Points2';
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        ou_overs => {
            from => sub { my $self = shift; $self->ou_overs_game (@_) },
            wins => sub { my $self = shift; $self->ou_overs_win (@_) },
        },
        ou_unders => {
            from => sub { my $self = shift; $self->ou_unders_game (@_) },
            wins => sub { my $self = shift; $self->ou_unders_win (@_) },
        },
    };
}

sub ou_overs_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n >= 2.5 && $data->{ou_points2} >= $n;
    return 0;
}

sub ou_overs_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n >= 2.5
             && $data->{ou_points2} >= $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

sub ou_unders_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n < 2.5 && $data->{ou_points2} < $n;
    return 0;
}

sub ou_unders_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n < 2.5
             && $data->{ou_points2} <= $n
             && $data->{home_score} + $data->{away_score} < 2.5;
    return 0;
}

=pod

=head1 NAME

Football/BenchTest/OU_Points_Model2.pm

=head1 SYNOPSIS

used by backtest.pl

=head1 DESCRIPTION

Methods to test validity of results from OU_Points_Model

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
