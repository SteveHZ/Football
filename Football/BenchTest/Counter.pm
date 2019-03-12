package Football::BenchTest::Counter;

use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Goal_Diffs_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::OU_Points_Model;
use Data::Dumper;

#has 'ou_pts' => (is => 'ro');
#has 'test_data' => (is => 'ro', default => sub {[]});

use Moo;
use namespace::clean;

sub BUILD {
    my $self = shift;

    $self->{expect_model} = Football::BenchTest::Goal_Expect_Model->new ();
    $self->{gd_model} = Football::BenchTest::Goal_Diffs_Model->new();
    $self->{ou_model} = Football::BenchTest::Over_Under_Model->new();
    $self->{ou_pts_model} = Football::BenchTest::OU_Points_Model->new();
    $self->{models} = [ values %$self ];

    for my $model (@{ $self->{models} }) {
        for my $key (@{ $model->keys }) {
            for my $i (@{ $model->range }) {
                $self->{$key}->{$i} = { wins => 0, from => 0, };
            }
        }
    }
}

sub do_counts {
    my ($self, $data) = @_;

    for my $model (@{ $self->{models} }) {
        my @keys = @{ $model->keys };
        next if $keys[0] eq 'ou_points';
        for my $n (@{ $model->range }) {
            $self->{ $keys [0] }->{$n}->{from} ++ if $model->home_away_game ($data, $n);
            $self->{ $keys [0] }->{$n}->{wins} ++ if $model->home_away_win ($data, $n);
            $self->{ $keys [1] }->{$n}->{from} ++ if $model->last_six_game ($data, $n);
            $self->{ $keys [1] }->{$n}->{wins} ++ if $model->last_six_win ($data, $n);
            $self->{ $keys [2] }->{$n}->{from} ++ if $model->ha_lsx_game ($data, $n);
            $self->{ $keys [2] }->{$n}->{wins} ++ if $model->ha_lsx_win ($data, $n);
        }
    }
    for my $n (@{ $self->{ou_pts_model}->range }) {
        $self->{ou_points}->{$n}->{from} ++ if $self->{ou_pts_model}->ou_points_game ($data, $n);
        $self->{ou_points}->{$n}->{wins} ++ if $self->{ou_pts_model}->ou_points_win ($data, $n);
    }
#push @test_
}

=head
sub do_count {
    my ($self, $data, $n) = @_;

# can all this be done simpler with a dispatch table ??
    $self->{home_away}->{$n}->{from} ++ if $self->{expect_model}->home_away_game ($data, $n);
    $self->{home_away}->{$n}->{wins} ++ if $self->{expect_model}->home_away_win ($data, $n);
    $self->{last_six}->{$n}->{from} ++ if $self->{expect_model}->last_six_game ($data, $n);
    $self->{last_six}->{$n}->{wins} ++ if $self->{expect_model}->last_six_win ($data, $n);
    $self->{ha_lsx}->{$n}->{from} ++ if $self->{expect_model}->ha_lsx_game ($data, $n);
    $self->{ha_lsx}->{$n}->{wins} ++ if $self->{expect_model}->ha_lsx_win ($data, $n);

    $self->{gd_home_away}->{$n}->{from} ++ if $self->{gd_model}->home_away_game ($data, $n);
    $self->{gd_home_away}->{$n}->{wins} ++ if $self->{gd_model}->home_away_win ($data, $n);
    $self->{gd_last_six}->{$n}->{from} ++ if $self->{gd_model}->last_six_game ($data, $n);
    $self->{gd_last_six}->{$n}->{wins} ++ if $self->{gd_model}->last_six_win ($data, $n);
    $self->{gd_ha_lsx}->{$n}->{from} ++ if $self->{gd_model}->ha_lsx_game ($data, $n);
    $self->{gd_ha_lsx}->{$n}->{wins} ++ if $self->{gd_model}->ha_lsx_win ($data, $n);
}

sub do_over_under {
    my ($self, $data, $n) = @_;

    $self->{ou_home_away}->{$n}->{from} ++ if $self->{ou_model}->home_away_game ($data, $n);
    $self->{ou_home_away}->{$n}->{wins} ++ if $self->{ou_model}->home_away_win ($data, $n);
    $self->{ou_last_six}->{$n}->{from} ++ if $self->{ou_model}->last_six_game ($data, $n);
    $self->{ou_last_six}->{$n}->{wins} ++ if $self->{ou_model}->last_six_win ($data, $n);
    $self->{ou_ha_lsx}->{$n}->{from} ++ if $self->{ou_model}->ha_lsx_game ($data, $n);
    $self->{ou_ha_lsx}->{$n}->{wins} ++ if $self->{ou_model}->ha_lsx_win ($data, $n);
}
=cut

#   Hash accessors

sub home_away_wins {
    my ($self, $n) = @_;
    return $self->{home_away}->{$n}->{wins};
}

sub home_away_games {
    my ($self, $n) = @_;
    return $self->{home_away}->{$n}->{from};
}

sub last_six_wins {
    my ($self, $n) = @_;
    return $self->{last_six}->{$n}->{wins};
}

sub last_six_games {
    my ($self, $n) = @_;
    return $self->{last_six}->{$n}->{from};
}

sub ha_lsx_wins {
    my ($self, $n) = @_;
    return $self->{ha_lsx}->{$n}->{wins};
}

sub ha_lsx_games {
    my ($self, $n) = @_;
    return $self->{ha_lsx}->{$n}->{from};
}

sub ou_home_away_wins {
    my ($self, $n) = @_;
    return $self->{ou_home_away}->{$n}->{wins};
}

sub ou_home_away_games {
    my ($self, $n) = @_;
    return $self->{ou_home_away}->{$n}->{from};
}

sub ou_last_six_wins {
    my ($self, $n) = @_;
    return $self->{ou_last_six}->{$n}->{wins};
}

sub ou_last_six_games {
    my ($self, $n) = @_;
    return $self->{ou_last_six}->{$n}->{from};
}

sub ou_ha_lsx_wins {
    my ($self, $n) = @_;
    return $self->{ou_ha_lsx}->{$n}->{wins};
}

sub ou_ha_lsx_games {
    my ($self, $n) = @_;
    return $self->{ou_ha_lsx}->{$n}->{from};
}

sub ou_points_wins {
    my ($self, $n) = @_;
    return $self->{ou_points}->{$n}->{wins};
}

sub ou_points_games {
    my ($self, $n) = @_;
    return $self->{ou_points}->{$n}->{from};
}

sub gd_home_away_wins {
    my ($self, $n) = @_;
    return $self->{gd_home_away}->{$n}->{wins};
}

sub gd_home_away_games {
    my ($self, $n) = @_;
    return $self->{gd_home_away}->{$n}->{from};
}

sub gd_last_six_wins {
    my ($self, $n) = @_;
    return $self->{gd_last_six}->{$n}->{wins};
}

sub gd_last_six_games {
    my ($self, $n) = @_;
    return $self->{gd_last_six}->{$n}->{from};
}

sub gd_ha_lsx_wins {
    my ($self, $n) = @_;
    return $self->{gd_ha_lsx}->{$n}->{wins};
}

sub gd_ha_lsx_games {
    my ($self, $n) = @_;
    return $self->{gd_ha_lsx}->{$n}->{from};
}

1;
