package Football::BenchTest::Over_Under_Model;

use Football::BenchTest::Counter;
use Moo;
use namespace::clean;

#has 'keys' => (is =>'ro');
#has 'headings' => (is => 'ro');
#has 'range' => (is =>'ro');
#has 'counter' => (is => 'ro');
#has 'sheetname' => (is => 'ro', default => 'Over Unders');
#has 'dispatch' => (is => 'ro', builder => '_build_dispatch');

with 'Football::Roles::Counter';

sub BUILD {
    my $self = shift;
    $self->{keys} = [ qw(ou_home_away ou_last_six ou_ha_lsx) ];
    $self->{headings} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{range} = [ 0.5,0.6,0.7,0.8,0.9,1 ];
    $self->{sheetname} = 'Over Unders';
##    $self->{counter} = Football::BenchTest::Counter->new (model => $self);
}

sub _build_dispatch {
    my $self = shift;
    $self->{dispatch} = {
        ou_home_away => {
            from => \&Football::BenchTest::Over_Under_Model::home_away_game,
            wins => \&Football::BenchTest::Over_Under_Model::home_away_win,
        },
        ou_last_six => {
            from => \&Football::BenchTest::Over_Under_Model::last_six_game,
            wins => \&Football::BenchTest::Over_Under_Model::last_six_win,
        },
        ou_ha_lsx => {
            from => \&Football::BenchTest::Over_Under_Model::ha_lsx_game,
            wins => \&Football::BenchTest::Over_Under_Model::ha_lsx_win,
        },
    };
}

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
