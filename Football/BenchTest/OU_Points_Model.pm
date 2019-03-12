package Football::BenchTest::OU_Points_Model;

use Moo;
use namespace::clean;

has 'keys' => (is =>'ro', builder => '_build_keys');
has 'range' => (is =>'ro', builder => '_build_range');
has 'over_range' => (is =>'ro', builder => '_build_over_range');
has 'under_range' => (is =>'ro', builder => '_build_under_range');

sub _build_keys {
    return [ qw(ou_points) ];
}

sub _build_range {
    return [ -10,-9,-8,-7,-6,-5,5,6,7,8,9,10 ];
}

sub _build_over_range {
    return [ 5,6,7,8,9,10 ];
}

sub _build_under_range {
    return [ -5,-6,-7,-8,-9,-10 ];
}

sub ou_points_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n >= 5 && $data->{ou_points} >= $n;
    return 1 if $n <= -5 && $data->{ou_points} <= $n;
    return 0;
}

sub ou_points_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n >= 5
             && $data->{ou_points} >= $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 1 if $n <= -5
             && $data->{ou_points} <= $n
             && $data->{home_score} + $data->{away_score} < 2.5;
    return 0;
}

1;
