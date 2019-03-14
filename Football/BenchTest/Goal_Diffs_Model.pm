package Football::BenchTest::Goal_Diffs_Model;

use Football::BenchTest::Counter;
use List::MoreUtils qw(true);
use Moo;
use namespace::clean;

has 'keys' => (is =>'ro');
has 'headings' => (is => 'ro');
has 'range' => (is =>'ro');
has 'counter' => (is => 'ro');
has 'dispatch' => (is => 'ro', builder => '_build_dispatch');
has 'sheetname' => (is => 'ro', default => 'Goal Diffs');

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(gd_home_away gd_last_six gd_ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0,0.5,1,1.5,2,2.5,3 ];
    $self->{counter} = Football::BenchTest::Counter->new (model => $self);
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

#   Methods for single data items

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

=head
sub get_results {
    my ($self, $week, $expect_data) = @_;
    for my $i (@{ $self->{range} }) {
        $week->{gd_home_away}->{$i} = {
            wins => $self->count_home_away_wins ($expect_data, $i),
            from => $self->count_home_away_games ($expect_data, $i),
        };
        $week->{gd_last_six}->{$i} = {
            wins => $self->count_last_six_wins ($expect_data, $i),
            from => $self->count_last_six_games ($expect_data, $i),
        };
        $week->{gd_ha_lsx}->{$i} = {
            wins => $self->count_ha_lsx_wins ($expect_data, $i),
            from => $self->count_ha_lsx_games ($expect_data, $i),
        };
        print "\n\nHome Away $i : ". $week->{gd_home_away}->{$i}->{wins}.' from '.$week->{gd_home_away}->{$i}->{from};
        print "\nLast Six  $i : ". $week->{gd_last_six}->{$i}->{wins}.' from '.$week->{gd_last_six}->{$i}->{from};
        print "\nBoth      $i : ". $week->{gd_ha_lsx}->{$i}->{wins}.' from '.$week->{gd_ha_lsx}->{$i}->{from};
    }
}

sub update_totals {
    my ($self, $week, $totals) = @_;

    for my $key (@{ $self->keys }) {
        for my $i (@{ $self->{range} }) {
            $totals->{$key}->{$i}->{wins} += $week->{$key}->{$i}->{wins};
            $totals->{$key}->{$i}->{from} += $week->{$key}->{$i}->{from};
        }
    }
}

#   Methods to return count of successful data

sub count_home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        abs $_->{home_away_goal_diff} > $n
    } @$data;
}

sub count_home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{home_away_goal_diff} > $n && $_->{result} eq 'H' )
        or ( $_->{home_away_goal_diff} < ($n * -1) && $_->{result} eq 'A')
    } @$data;
}

sub count_last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        abs $_->{last_six_goal_diff} > $n
    } @$data;
}

sub count_last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{last_six_goal_diff} > $n && $_->{result} eq 'H' )
        or ( $_->{last_six_goal_diff} < ($n * -1) && $_->{result} eq 'A')
    } @$data;
}

sub count_ha_lsx_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        ( $_->{home_away_goal_diff} > $n && $_->{last_six_goal_diff} > $n )
        or ( $_->{home_away_goal_diff} < ($n * -1) && $_->{last_six_goal_diff} < ($n * -1))
    } @$data;
}

sub count_ha_lsx_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return true {
        (( $_->{home_away_goal_diff} > $n && $_->{result} eq 'H' )
        or ( $_->{home_away_goal_diff} < ($n * -1) && $_->{result} eq 'A'))
    &&
        (( $_->{last_six_goal_diff} > $n && $_->{result} eq 'H' )
        or ( $_->{last_six_goal_diff} < ($n * -1) && $_->{result} eq 'A'))
    } @$data;
}

#   Methods to return arrayrefs of successful data

sub home_away_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            abs $_->{home_away_goal_diff} > $n
        } @$data
    ];
}

sub home_away_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            ( $_->{home_away_goal_diff} > $n && $_->{result} eq 'H' )
            or ( $_->{home_away_goal_diff} < ($n * -1) && $_->{result} eq 'A')
        } @$data
    ];
}

sub last_six_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            abs $_->{last_six_goal_diff} > $n
        } @$data
    ];
}

sub last_six_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            ( $_->{last_six_goal_diff} > $n && $_->{result} eq 'H' )
            or ( $_->{last_six_goal_diff} < ($n * -1) && $_->{result} eq 'A')
        } @$data
    ];
}

sub ha_lsx_games {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            ( $_->{home_away_goal_diff} > $n && $_->{last_six_goal_diff} > $n )
            or ( $_->{home_away_goal_diff} < ($n * -1) && $_->{last_six_goal_diff} < ($n * -1))
        } @$data
    ];
}

sub ha_lsx_wins {
    my ($self, $data, $n) = @_;
    $n //= 0;
    return [
        grep {
            (( $_->{home_away_goal_diff} > $n && $_->{result} eq 'H' )
            or ( $_->{home_away_goal_diff} < ($n * -1) && $_->{result} eq 'A'))
        &&
            (( $_->{last_six_goal_diff} > $n && $_->{result} eq 'H' )
            or ( $_->{last_six_goal_diff} < ($n * -1) && $_->{result} eq 'A'))
        } @$data
    ];
}
=cut
