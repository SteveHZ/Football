package Football::BenchTest::Over_Under_Model;

use Football::Over_Under_Model;
use Moo;
use namespace::clean;

extends 'Football::Over_Under_Model';

sub count_home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{home_away} > $n
    } @$data;
}

sub count_home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{home_away} > $n && $_->{over_under}->{goals} > 2.5 )
    } @$data;
}

sub count_last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{last_six} > $n
    } @$data;
}

sub count_last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{last_six} > $n && $_->{over_under}->{goals} > 2.5 )
        or ( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'A')
    } @$data;
}
#???
sub count_ou_points_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{ou_points} > $n && $_->{expected_goal_diff_last_six} > $n )
        or ( $_->{expected_goal_diff} < ($n * -1) && $_->{expected_goal_diff_last_six} < ($n * -1))
    } @$data;
}

sub count_ha_lsx_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        (( $_->{expected_goal_diff} > $n && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff} < ($n * -1) && $_->{result} eq 'A'))
    &&
        (( $_->{expected_goal_diff_last_six} > $n && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'A'))
    } @$data;
}

sub count_ha_lsx_lost {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        (( $_->{expected_goal_diff} < ($n * -1) && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff} > $n && $_->{result} eq 'A'))
    &&
        (( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff_last_six} > $n && $_->{result} eq 'A'))
    } @$data;
}


1;
