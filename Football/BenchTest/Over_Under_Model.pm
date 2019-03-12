package Football::BenchTest::Over_Under_Model;

use List::MoreUtils qw(true);
use Moo;
use namespace::clean;

has 'keys' => (is =>'ro', builder => '_build_keys');
has 'range' => (is =>'ro', builder => '_build_range');

sub _build_keys {
    return [ qw(ou_home_away ou_last_six ou_ha_lsx ou_points) ];
}

sub _build_range {
    return [ 0.5,0.6,0.7,0.8,0.9,1 ];
}

=head
sub get_results {
    my ($self, $week, $expect_data) = @_;
    for my $i (@{ $self->{range} }) {
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

    for my $key (@{ $self->keys }) {
        for my $i (@{ $self->{range} }) {
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
=cut

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

sub home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_home_away} > $n
        } @$data
    ];
}

sub home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_home_away} > $n && $_->{over_under}->{goals} > 2.5
        } @$data
    ];
}

sub last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_last_six} > $n
        } @$data
    ];
}

sub last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_last_six} > $n && $_->{over_under}->{goals} > 2.5
        } @$data
    ];
}

sub ha_lsx_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_home_away} > $n
            && $_->{ou_last_six} > $n
        } @$data
    ];
}

sub ha_lsx_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_home_away} > $n
            && $_->{ou_last_six} > $n
            && $_->{over_under}->{goals} > 2.5
        } @$data
    ];
}

sub ou_points_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_points} > $n
        } @$data
    ];
}

sub ou_points_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            $_->{ou_points} > $n && $_->{over_under}->{goals} > 2.5
        } @$data
    ];
}

#   Methods for single data items

sub home_away_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n;
    return 0;
}

sub home_away_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

sub last_six_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{last_six} > $n;
    return 0;
}

sub last_six_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{last_six} > $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

sub ha_lsx_game {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n
             && $data->{last_six} > $n;
    return 0;
}

sub ha_lsx_win {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return 1 if $data->{home_away} > $n
             && $data->{last_six} > $n
             && $data->{home_score} + $data->{away_score} > 2.5;
    return 0;
}

1;
