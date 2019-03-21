package Football::BenchTest::OU_Points_Model;

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
    $self->{range} = [ -10,-9,-8,-7,-6,-5,5,6,7,8,9,10 ];
    $self->{over_range} = [ 5,6,7,8,9,10 ];
    $self->{under_range} = [ -5,-6,-7,-8,-9,-10 ];
    $self->{sheetname} = 'OU Points';
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        ou_overs => {
            from => \&Football::BenchTest::OU_Points_Model::ou_overs_game,
            wins => \&Football::BenchTest::OU_Points_Model::ou_overs_win,
        },
        ou_unders => {
            from => \&Football::BenchTest::OU_Points_Model::ou_unders_game,
            wins => \&Football::BenchTest::OU_Points_Model::ou_unders_win,
        },
    };
}

sub ou_overs_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n >= 5 && $data->{ou_points} >= $n;
    return 0;
}

sub ou_overs_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n >= 5
             && $data->{ou_points} >= $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

sub ou_unders_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n <= -5 && $data->{ou_points} <= $n;
    return 0;
}

sub ou_unders_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $n <= -5
             && $data->{ou_points} <= $n
             && $data->{home_score} + $data->{away_score} < 2.5;
    return 0;
}

1;
