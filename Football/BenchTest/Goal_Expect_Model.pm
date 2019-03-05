package Football::BenchTest::Goal_Expect_Model;

use List::MoreUtils qw(true);
use Moo;
use namespace::clean;

has 'keys' => (is =>'ro', builder => '_build_keys');

sub _build_keys {
    return [ qw(home_away last_six ha_lsx) ];
}

sub get_results {
    my ($self, $week, $expect_data) = @_;
    for (my $i = 0; $i <= 3; $i += 0.5) {
        $week->{home_away}->{$i} = {
            wins => $self->count_home_away_wins ($expect_data, $i),
            from => $self->count_home_away_games ($expect_data, $i),
        };
        $week->{last_six}->{$i} = {
            wins => $self->count_last_six_wins ($expect_data, $i),
            from => $self->count_last_six_games ($expect_data, $i),
        };
        $week->{ha_lsx}->{$i} = {
            wins => $self->count_ha_lsx_wins ($expect_data, $i),
            from => $self->count_ha_lsx_games ($expect_data, $i),
        };
        print "\n\nHome Away $i : ". $week->{home_away}->{$i}->{wins}.' from '.$week->{home_away}->{$i}->{from};
        print "\nLast Six  $i : ". $week->{last_six}->{$i}->{wins}.' from '.$week->{last_six}->{$i}->{from};
        print "\nBoth      $i : ". $week->{ha_lsx}->{$i}->{wins}.' from '.$week->{ha_lsx}->{$i}->{from};
    }
}

sub update_totals {
    my ($self, $week, $totals) = @_;
    my $keys = $self->keys;
    for my $key (@$keys) {
        for (my $i = 0; $i <=3; $i+=0.5) {
            $totals->{$key}->{$i}->{wins} += $week->{$key}->{$i}->{wins};
            $totals->{$key}->{$i}->{from} += $week->{$key}->{$i}->{from};
        }
    }
}

#   Should all methods below be in a role ??
#   Methods to return count of successful data

sub count_home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{expected_goal_diff} > $n
        or $_->{expected_goal_diff} < ($n * -1)
    } @$data;
}

sub count_home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{expected_goal_diff} > $n && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff} < ($n * -1) && $_->{result} eq 'A')
    } @$data;
}

sub count_last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{expected_goal_diff_last_six} > $n
        or $_->{expected_goal_diff_last_six} < ($n * -1)
    } @$data;
}

sub count_last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{expected_goal_diff_last_six} > $n && $_->{result} eq 'H' )
        or ( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'A')
    } @$data;
}

sub count_ha_lsx_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{expected_goal_diff} > $n && $_->{expected_goal_diff_last_six} > $n )
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

#   Methods to return arrayrefs of successful data

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
        grep {
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
        grep {
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
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            (( $_->{expected_goal_diff} < ($n * -1) && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff} > $n && $_->{result} eq 'A'))
        &&
            (( $_->{expected_goal_diff_last_six} < ($n * -1) && $_->{result} eq 'H' )
            or ( $_->{expected_goal_diff_last_six} > $n && $_->{result} eq 'A'))
        } @$data
    ];
}

#   Methods for single data items

sub home_away_game {
    my ($self, $expect, $n) = @_;
    $n //= 0;
    return 1 if abs ( $expect->{expected_goal_diff} ) > $n;
    return 0;
}

sub home_away_win {
    my ($self, $expect, $n) = @_;
    $n //= 0;
    return 1 if ($expect->{home_score} > $expect->{away_score} && $expect->{expected_goal_diff} > $n )
             or ($expect->{away_score} > $expect->{home_score} && $expect->{expected_goal_diff} < ($n * -1));
    return 0;
}

sub last_six_game {
    my ($self, $expect, $n) = @_;
    $n //= 0;
    return 1 if abs( $expect->{expected_goal_diff_last_six} ) > $n;
    return 0;
}

sub last_six_win {
    my ($self, $expect, $n) = @_;
    $n //= 0;
    return 1 if ($expect->{home_score} > $expect->{away_score} && $expect->{expected_goal_diff_last_six} > $n )
    or ($expect->{away_score} > $expect->{home_score} && $expect->{expected_goal_diff_last_six} < ($n * -1) );
    return 0;
}

sub ha_lsx_game {
    my ($self, $expect, $n) = @_;
    $n //= 0;
    return 1 if abs ( $expect->{expected_goal_diff} ) > $n
             && abs ( $expect->{expected_goal_diff_last_six} ) > $n;
    return 0;
}

sub ha_lsx_win {
    my ($self, $expect, $n) = @_;
    $n //= 0;
    return 1 if (($expect->{home_score} > $expect->{away_score} && $expect->{expected_goal_diff} > $n )
             or ($expect->{away_score} > $expect->{home_score} && $expect->{expected_goal_diff} < ($n * -1) ))
        &&
            (($expect->{home_score} > $expect->{away_score} && $expect->{expected_goal_diff_last_six} > $n )
             or ($expect->{away_score} > $expect->{home_score} && $expect->{expected_goal_diff_last_six} < ($n * -1) ));
    return 0;
}

1;
