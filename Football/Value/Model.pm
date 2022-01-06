package Football::Value::Model;

use List::MoreUtils qw(each_array);
use File::Fetch;
use Math::Round qw(nearest);

use Football::Globals qw(@league_names @csv_leagues);
use Football::Football_Data_Model;

use Moo;
use namespace::clean;

has 'overround' => (is => 'rw', default => 1.05);

sub download_fdata {
    my $self = shift;
    my $dir = 'C:/Mine/perl/Football/data/value';
    my $url = "https://www.football-data.co.uk/fixtures.csv";

    my $ff = File::Fetch->new (uri => $url);
    my $file = $ff->fetch (to => $dir) or die $ff->error;
    print "\nDownloading $file...";
    return $file;
}

sub get_fdata {
    my ($self, $csv_file) = @_;

    my $data_model = Football::Football_Data_Model->new (
        'my_keys'       => [ qw(league home_team b365h b365a b365d b365over b365under) ],
        'skip_blanks'   => 0,
    );
    my $games = $data_model->read_csv ($csv_file);

    my $fdata = {};
    my $iterator = each_array (@league_names, @csv_leagues);
    while (my ($league, $csv) = $iterator->()) {
        my @league_games = grep { $_->{league} eq $csv } @$games;
        for my $game (@league_games) {
            my $home = $game->{home_team};
            $fdata->{$home} = $game;
        }
    }
    return $fdata;
}

sub collate_data {
    my ($self, $mine, $fdata) = @_;

    for my $game (@$mine) {
        my $home = $game->{home_team};
        $game->{fdata} = $fdata->{$home};
    }
    return $mine;
}

sub calc_data {
    my ($self, $mine) = @_;

    return {
        home_win => $self->get_home_win ($mine),
        away_win => $self->get_away_win ($mine),
        draw => $self->get_draw ($mine),
        over_2pt5 => $self->get_over_2pt5 ($mine),
        under_2pt5 => $self->get_under_2pt5 ($mine),
        home_double => $self->get_home_double ($mine),
        away_double => $self->get_away_double ($mine),
    };
}

sub get_home_win {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{home_win} <=> $b->{home_win}
        } grep {
            $_->{home_win} < 2.30               #   are we interested ?
            && defined $_->{fdata}              #   do we have football-data info ?
            && $_->{fdata}->{b365h} ne ''       #   -------------""----------------
            && $_->{home_win} * $self->{overround} < $_->{fdata}->{b365h}
        } @$mine
    ];
}

sub get_draw {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{draw} <=> $b->{draw}
        } grep {
            $_->{draw} < 3
            && defined $_->{fdata}
            && $_->{draw} < $_->{home_win}
            && $_->{draw} < $_->{away_win}
        } @$mine
    ];
}

sub get_away_win {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{away_win} <=> $b->{away_win}
        } grep {
            $_->{away_win} < 2.30
            && defined $_->{fdata}
            && $_->{fdata}->{b365a} ne ''
            && $_->{away_win} * $self->{overround} < $_->{fdata}->{b365a}
        } @$mine
    ];
}

sub get_over_2pt5 {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{over_2pt5} <=> $b->{over_2pt5}
        } grep {
            defined $_->{fdata}
            && $_->{fdata}->{b365over} ne ''
            && $_->{over_2pt5} * $self->{overround} < $_->{fdata}->{b365over}
        } @$mine
    ];
}

sub get_under_2pt5 {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{under_2pt5} <=> $b->{under_2pt5}
        } grep {
            defined $_->{fdata}
            && $_->{fdata}->{b365under} ne ''
            && $_->{under_2pt5} * $self->{overround} < $_->{fdata}->{b365under}
        } @$mine
    ];
}

sub get_home_double {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{home_win} <=> $b->{home_win}
        } grep {
            defined $_->{fdata}              #   do we have football-data info ?
            && $_->{fdata}->{b365h} ne ''    #   -------------""----------------
            && $_->{fdata}->{b365d} ne ''
            && $_->{home_double} * $self->{overround}
             < _calc_double_chance ($_->{fdata}->{b365h}, $_->{fdata}->{b365d})
        } @$mine
    ];
}

sub get_away_double {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{away_win} <=> $b->{away_win}
        } grep {
            defined $_->{fdata}              #   do we have football-data info ?
            && $_->{fdata}->{b365a} ne ''    #   -------------""----------------
            && $_->{fdata}->{b365d} ne ''
            && $_->{away_double} * $self->{overround}
             < _calc_double_chance ($_->{fdata}->{b365a}, $_->{fdata}->{b365d})
        } @$mine
    ];
}

sub _calc_double_chance {
    my ($win, $draw) = @_;
    return nearest (0.01, 100 /(( 100/$win ) + (100/$draw)));
}

#   for testing
sub calc_double_chance {
    my $self = shift;
    return _calc_double_chance (@_);
}

1;
