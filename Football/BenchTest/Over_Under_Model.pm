package Football::BenchTest::Over_Under_Model;

use List::MoreUtils qw(true);
use Football::Over_Under_Model;
use Moo;
use namespace::clean;

extends 'Football::Over_Under_Model';

has 'keys' => (is =>'ro', builder => '_build_keys');

sub _build_keys {
    return [ qw(ou_home_away ou_last_six ou_points) ];
}

sub init_totals {
    my $self = shift;
    my $totals = {};

    for my $key (@{ $self->{keys} }) {
        if ($key eq 'ou_points') {
            for (my $i = 5; $i <= 10; $i++) {
                $totals->{$key}->{$i}->{wins} = 0;
                $totals->{$key}->{$i}->{from} = 0;
            }
        } else {
            for (my $i = 0.5; $i <= 1; $i += 0.1) {
                $totals->{$key}->{$i}->{wins} = 0;
                $totals->{$key}->{$i}->{from} = 0;
            }
        }
    }
    return $totals;
}

sub get_results {
    my ($self, $results, $expect_data) = @_;
    for (my $i = 0.5; $i <= 1; $i += 0.1) {
        $results->{ou_home_away}->{$i} = {
            wins => $self->count_home_away_wins ($expect_data, $i),
            from => $self->count_home_away_games ($expect_data, $i),
        };
        $results->{ou_last_six}->{$i} = {
            wins => $self->count_last_six_wins ($expect_data, $i),
            from => $self->count_last_six_games ($expect_data, $i),
        };
        my $j = $i * 10;
        $results->{ou_points}->{$j} = {
            wins => $self->count_ou_points_wins ($expect_data, $j),
            from => $self->count_ou_points_games ($expect_data, $j),
        };
        print "\n\nOU_Home Away $i : ". $results->{ou_home_away}->{$i}->{wins}.' from '.$results->{ou_home_away}->{$i}->{from};
        print "\nOU_Last Six  $i : ". $results->{ou_last_six}->{$i}->{wins}.' from '.$results->{ou_last_six}->{$i}->{from};
        print "\nOU_Points    $j : ". $results->{ou_points}->{$j}->{wins}.' from '.$results->{ou_points}->{$j}->{from};
    }
}

sub update_totals {
    my ($self, $totals, $results_data) = @_;
    $self->init_totals ($totals);
    my $keys = $self->keys;

    for my $week (0...$#$results_data) {
        for my $key (@$keys) {
            for (my $i = 0.5; $i <= 1; $i += 0.1) {
                if ($key eq 'ou_points') {
                    my $j = $i * 10;
                    $totals->{$key}->{$j}->{wins} += @$results_data [$week]->{$key}->{$j}->{wins};
                    $totals->{$key}->{$j}->{from} += @$results_data [$week]->{$key}->{$j}->{from};
                } else {
                    $totals->{$key}->{$i}->{wins} += @$results_data [$week]->{$key}->{$i}->{wins};
                    $totals->{$key}->{$i}->{from} += @$results_data [$week]->{$key}->{$i}->{from};
                }
            }
        }
    }
}

sub count_home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_home_away} > $n
    } @$data;
}

sub count_home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_home_away} > $n && $_->{over_under}->{goals} > 2.5
    } @$data;
}

sub count_last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_last_six} > $n
    } @$data;
}

sub count_last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_last_six} > $n && $_->{over_under}->{goals} > 2.5
    } @$data;
}

sub count_ou_points_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_points} > $n
    } @$data;
}

sub count_ou_points_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_points} > $n && $_->{over_under}->{goals} > 2.5
    } @$data;
}

#???
=head
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
=cut

1;
