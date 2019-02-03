package Football::BenchTest::Goal_Expect_Model;

use Football::Goal_Expect_Model;
use Moo;
use namespace::clean;

extends 'Football::Goal_Expect_Model';

sub BUILD {
#    print "\nIn Goal Expect Benchtest model";
}

sub write_goal_expect {} # temp for analyse.pl

sub home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{expected_goal_diff} > $n
            or $_->{expected_goal_diff} < ($n * -1)
        } @$data
    ];
}

sub home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        sort {
            $b->{expected_goal_diff} <=> $a->{expected_goal_diff}
        } grep {
            ( $_->{expected_goal_diff} > $n && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff} < ($n * -1) && $_->{result} eq 'A')
        } @$data
    ];
}

sub last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{expected_goal_diff_last_six} > $n
            or $_->{expected_goal_diff_last_six} < ($n * -1)
        } @$data
    ];
}

sub last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        sort {
            $b->{expected_goal_diff_last_six} <=> $a->{expected_goal_diff_last_six}
        } grep {
            ( $_->{expected_goal_diff_last_six} > $n && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'A')
        } @$data
    ];
}

sub ha_lsx_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            ( $_->{expected_goal_diff} > $n && $_->{expected_goal_diff_last_six} > $n )
            or ( $_->{expected_goal_diff} < ($n * -1) && $_->{expected_goal_diff_last_six} < ($n * -1))
        } @$data
    ];
}

sub ha_lsx_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            (( $_->{expected_goal_diff} > $n && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff} < ($n * -1) && $_->{result} eq 'A'))
        &&
            (( $_->{expected_goal_diff_last_six} > $n && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'A'))
        } @$data
    ];
}

sub ha_lsx_lost {
    my ($self, $data) = @_;
    return [
        grep {
            (( $_->{expected_goal_diff} < 0 && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff} > 0 && $_->{result} eq 'A'))
        &&
            (( $_->{expected_goal_diff_last_six} < 0 && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff_last_six} > 0 && $_->{result} eq 'A'))
        } @$data
    ];
}

1;
