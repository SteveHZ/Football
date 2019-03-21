package Football::BenchTest::Goal_Expect_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

with 'Football::BenchTest::Roles::ModelBase';

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(home_away last_six ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0,0.5,1,1.5,2,2.5,3 ];
    $self->{sheetname} = 'Goal Expects';
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        home_away => {
            from => \&Football::BenchTest::Goal_Expect_Model::home_away_game,
            wins => \&Football::BenchTest::Goal_Expect_Model::home_away_win,
        },
        last_six => {
            from => \&Football::BenchTest::Goal_Expect_Model::last_six_game,
            wins => \&Football::BenchTest::Goal_Expect_Model::last_six_win,
        },
        ha_lsx => {
            from => \&Football::BenchTest::Goal_Expect_Model::ha_lsx_game,
            wins => \&Football::BenchTest::Goal_Expect_Model::ha_lsx_win,
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

1;
