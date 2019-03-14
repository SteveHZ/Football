package Football::BenchTest::Counter;

use Moo;
use namespace::clean;

has 'model' => (is => 'ro');

sub BUILD {
    my $self = shift;
    for my $key (@{ $self->model->keys } ) {
        for my $i (@{ $self->model->range } ) {
            $self->{$key}->{$i} = { wins => 0, from => 0, };
        }
    }
}

sub do_counts {
    my ($self, $data) = @_;

    for my $n (@{ $self->model->range } ) {
        for my $key (@{ $self->model->keys } ) {
#call a dispatch finction here self->model->dispatch/do_func (self,key,from/wins,data,n) ??
            $self->{$key}->{$n}->{from} ++ if $self->model->dispatch->{$key}->{from}->($self, $data, $n);
            $self->{$key}->{$n}->{wins} ++ if $self->model->dispatch->{$key}->{wins}->($self, $data, $n);
        }
    }
}

sub get_hashref {
    my ($self, $key, $n) = @_;
    return $self->{$key}->{$n};
}

sub get_data {
    my ($self, $key, $n) = @_;
    return ( $self->{$key}->{$n}->{wins}, $self->{$key}->{$n}->{from} );
}

sub wins {
    my ($self, $key, $n) = @_;
    return $self->{$key}->{$n}->{wins};
}

sub from {
    my ($self, $key, $n) = @_;
    return $self->{$key}->{$n}->{from};
}

#sub wins {
#    my $hashref = shift;
#    return $hashref->{wins};
#}

#my $hashref = $counter->{$key}->{$i};
#{ $hashref->{wins} => $self->{format} },
#{ $hashref->{from} => $self->{format} },
=head
model::do_func would be
sub func{
@_; potental probs with different $self ?? use $caller ??
$self->dispatch->{$key}->(...)
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
