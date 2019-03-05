package Football::BenchTest::Counter;

use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::Goal_Diffs_Model;
use Moo;
use namespace::clean;

sub BUILD {
    my $self = shift;
    my @keys = ( qw(
        home_away last_six ha_lsx
        gd_home_away gd_last_six gd_ha_lsx
    ));
    my @range = (0,0.5,1,1.5,2,2.5,3);
    for my $i (@range) {
        for my $key (@keys) {
            $self->{$key}->{$i} = { wins => 0, from => 0, };
        }
    }

    my @ou_keys = ( qw(ou_home_away ou_last_six ou_ha_lsx));
    my @ou_rane = (0.5,0.6,0.7,0.8,0.9,1);
    for my $i (@ou_range) {
        for my $key (@ou_keys) {
            $self->{$key}->{$i} = { wins => 0, from => 0, };
        }
    }
    $self->{expect_model} = Football::BenchTest::Goal_Expect_Model->new ();
    $self->{ou_model} = Football::BenchTest::Over_Under_Model->new();
    $self->{gd_model} = Football::BenchTest::Goal_Diffs_Model->new();
}

sub do_count {
    my ($self, $data, $n) = @_;

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
