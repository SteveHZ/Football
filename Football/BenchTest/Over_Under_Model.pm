package Football::BenchTest::Over_Under_Model;

use List::MoreUtils qw(true);
use Data::Dumper;
use Moo;
use namespace::clean;

extends 'Football::Over_Under_Model';

has 'keys' => (is =>'ro', builder => '_build_keys');

sub _build_keys {
    return [ qw(ou_home_away ou_last_six ou_ha_lsx ou_points) ];
}

sub get_results {
    my ($self, $week, $expect_data) = @_;
    for (my $i = 0.5; $i <= 1; $i += 0.1) {
        $week->{ou_home_away}->{$i} = {
            wins => $self->count_home_away_wins ($expect_data, $i),
            from => $self->count_home_away_games ($expect_data, $i),
        };
        $week->{ou_last_six}->{$i} = {
            wins => $self->count_last_six_wins ($expect_data, $i),
            from => $self->count_last_six_games ($expect_data, $i),
        };
        $week->{ou_ha_lsx}->{$i} = {
            wins => $self->count_ha_lsx_wins ($expect_data, $i),
            from => $self->count_ha_lsx_games ($expect_data, $i),
        };
        my $j = $i * 10;
        $week->{ou_points}->{$j} = {
            wins => $self->count_ou_points_wins ($expect_data, $j),
            from => $self->count_ou_points_games ($expect_data, $j),
        };
        print "\n\nOU_Home Away $i : ". $week->{ou_home_away}->{$i}->{wins}.' from '.$week->{ou_home_away}->{$i}->{from};
        print "\nOU_Last Six  $i : ". $week->{ou_last_six}->{$i}->{wins}.' from '.$week->{ou_last_six}->{$i}->{from};
        print "\nOU_ha_lsx    $i : ". $week->{ou_ha_lsx}->{$i}->{wins}.' from '.$week->{ou_ha_lsx}->{$i}->{from};
        print "\nOU_Points    $j : ". $week->{ou_points}->{$j}->{wins}.' from '.$week->{ou_points}->{$j}->{from};
    }
}

sub update_totals {
    my ($self, $week, $totals) = @_;
    my $keys = $self->keys;

    for my $key (@$keys) {
        for (my $i = 0.5; $i <= 1; $i += 0.1) {
            if ($key eq 'ou_points') {
                my $j = $i * 10;
                $totals->{$key}->{$j}->{wins} += $week->{$key}->{$j}->{wins};
                $totals->{$key}->{$j}->{from} += $week->{$key}->{$j}->{from};
            } else {
                $totals->{$key}->{$i}->{wins} += $week->{$key}->{$i}->{wins};
                $totals->{$key}->{$i}->{from} += $week->{$key}->{$i}->{from};
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

sub count_ha_lsx_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_home_away} > $n
        && $_->{ou_last_six} > $n
    } @$data;
}

sub count_ha_lsx_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        $_->{ou_home_away} > $n
        && $_->{ou_last_six} > $n
        && $_->{over_under}->{goals} > 2.5
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

1;
