package Football::BenchTest::OU_Points_Model;

use Moo;
use namespace::clean;

use Football::BenchTest::Counter;
use List::MoreUtils qw(true);
use Moo;
use namespace::clean;

#these should be in a base class
has 'keys' => (is =>'ro');
has 'headings' => ( is => 'ro');
has 'range' => (is =>'ro');
has 'over_range' => (is =>'ro');
has 'under_range' => (is =>'ro');
has 'counter' => (is => 'ro');
has 'dispatch' => (is => 'ro', builder => '_build_dispatch');
has 'sheetname' => (is => 'ro', default => 'OU Points');

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(ou_points ou_points) ];
    $self->{headings} = ['Overs', 'Unders'];
    $self->{range} = [ -10,-9,-8,-7,-6,-5,5,6,7,8,9,10 ];
    $self->{over_range} = [ 5,6,7,8,9,10 ];
    $self->{under_range} = [ -5,-6,-7,-8,-9,-10 ];
    $self->{counter} = Football::BenchTest::Counter->new (model => $self);
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        ou_points => {
            from => \&Football::BenchTest::OU_Points_Model::ou_points_game,
            wins => \&Football::BenchTest::OU_Points_Model::ou_points_win,
        },
    };
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

=head
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
=cut
