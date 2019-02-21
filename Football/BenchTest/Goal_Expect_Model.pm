package Football::BenchTest::Goal_Expect_Model;

use List::MoreUtils qw(true);
use Football::Goal_Expect_Model;
use Moo;
use namespace::clean;

extends 'Football::Goal_Expect_Model';

has 'keys' => (is =>'ro', builder => '_build_keys');

sub _build_keys {
    return [ qw(home_away last_six ha_lsx) ];
}

sub init_totals {
    my ($self, $totals) = @_;
#    my $self = shift;
#    my $totals = {};

    for my $key (@{ $self->{keys} }) {
        for (my $i = 0; $i <= 3; $i += 0.5) {
            $totals->{$key}->{$i}->{wins} = 0;
            $totals->{$key}->{$i}->{from} = 0;
        }
    }
    return $totals;
}

sub get_results {
    my ($self, $results, $expect_data) = @_;
    for (my $i = 0; $i <= 3; $i += 0.5) {
        $results->{home_away}->{$i} = {
            wins => $self->count_home_away_wins ($expect_data, $i),
            from => $self->count_home_away_games ($expect_data, $i),
        };
        $results->{last_six}->{$i} = {
            wins => $self->count_last_six_wins ($expect_data, $i),
            from => $self->count_last_six_games ($expect_data, $i),
        };
        $results->{ha_lsx}->{$i} = {
            wins => $self->count_ha_lsx_wins ($expect_data, $i),
            from => $self->count_ha_lsx_games ($expect_data, $i),
        };
        print "\n\nHome Away $i : ". $results->{home_away}->{$i}->{wins}.' from '.$results->{home_away}->{$i}->{from};
        print "\nLast Six  $i : ". $results->{last_six}->{$i}->{wins}.' from '.$results->{last_six}->{$i}->{from};
        print "\nBoth      $i : ". $results->{ha_lsx}->{$i}->{wins}.' from '.$results->{ha_lsx}->{$i}->{from};
    }
}


sub update_totals {
    my ($self, $totals, $results_data) = @_;
    $self->init_totals ($totals);
#    my $totals = $expect_model->init_totals ();
    my $keys = $self->keys;
    for my $week (0...$#$results_data) {
        for my $key (@$keys) {
            for (my $i = 0; $i <=3; $i+=0.5) {
                $totals->{$key}->{$i}->{wins} += @$results_data [$week]->{$key}->{$i}->{wins};
                $totals->{$key}->{$i}->{from} += @$results_data [$week]->{$key}->{$i}->{from};
            }
        }
    }
}

#   Should all methods below be in  a role ??
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

1;
