package Football::BenchTest::Goal_Diffs_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

#has 'keys' => (is =>'ro');
#has 'headings' => (is => 'ro');
#has 'range' => (is =>'ro');
#has 'counter' => (is => 'ro');
#has 'sheetname' => (is => 'ro', default => 'Goal Diffs');
#has 'dispatch' => (is => 'ro', builder => '_build_dispatch');

with 'Football::Roles::Counter';

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(gd_home_away gd_last_six gd_ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0,0.5,1,1.5,2,2.5,3 ];
    $self->{sheetname} = 'Goal Diffs';
##    $self->{counter} = Football::BenchTest::Counter->new (model => $self);
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        gd_home_away => {
            from => \&Football::BenchTest::Goal_Diffs_Model::home_away_game,
            wins => \&Football::BenchTest::Goal_Diffs_Model::home_away_win,
        },
        gd_last_six => {
            from => \&Football::BenchTest::Goal_Diffs_Model::last_six_game,
            wins => \&Football::BenchTest::Goal_Diffs_Model::last_six_win,
        },
        gd_ha_lsx => {
            from => \&Football::BenchTest::Goal_Diffs_Model::ha_lsx_game,
            wins => \&Football::BenchTest::Goal_Diffs_Model::ha_lsx_win,
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

1;
