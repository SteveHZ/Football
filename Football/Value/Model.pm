package Football::Value::Model;

use List::MoreUtils qw(each_arrayref);
use File::Fetch;

use Football::Globals qw(@league_names @csv_leagues);
use Football::Football_Data_Model;

use Moo;
use namespace::clean;

has 'overround' => (is => 'rw', default => 1.05);

sub download_fdata {
    my $self = shift;
    my $dir = 'C:/Mine/perl/Football/data/value';
    my $url = "http://www.football-data.co.uk/fixtures.csv";

    my $ff = File::Fetch->new (uri => $url);
    my $file = $ff->fetch (to => $dir) or die $ff->error;
    print "\nDownloading $file...";
    return $file;
}

sub get_fdata {
    my ($self, $csv_file) = @_;

    my $data_model = Football::Football_Data_Model->new (
        'my_keys'       => [ qw(league home_team home_win away_win draw over_2pt5 under_2pt5) ],
        'skip_blanks'   => 0,
    );
    my $games = $data_model->read_csv ($csv_file);

    my $fdata = {};
    my $iterator = each_arrayref (\@league_names, \@csv_leagues);
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
    };
}

sub get_home_win {
    my ($self, $mine) = @_;
    return [
        sort {
            $a->{home_win} <=> $b->{home_win}
        } grep {
            $_->{home_win} < 2                  #   are we interested ?
            && defined $_->{fdata}              #   do we have football-data info ?
            && $_->{fdata}->{home_win} ne ''    #   -------------""----------------
            && $_->{home_win} * $self->{overround} < $_->{fdata}->{home_win}
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
            $_->{away_win} < 2
            && defined $_->{fdata}
            && $_->{fdata}->{away_win} ne ''
            && $_->{away_win} * $self->{overround} < $_->{fdata}->{away_win}
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
            && $_->{fdata}->{over_2pt5} ne ''
            && $_->{over_2pt5} * $self->{overround} < $_->{fdata}->{over_2pt5}
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
            && $_->{fdata}->{under_2pt5} ne ''
            && $_->{under_2pt5} * $self->{overround} < $_->{fdata}->{under_2pt5}
        } @$mine
    ];
}

1;
