use strict;
use warnings;

use Football::Model;

my $model = Football::Model->new ();
$model->quick_build ();

my @ou_points = ();
for my $game (@{$model->fixtures}) {
    my $league = $model->leagues->[$game->{league_idx}];
    my $hplyd = $league->home_played ($game->{home_team});
    my $aplyd = $league->away_played ($game->{away_team});

    my $points = 0;
    $points += ( $league->home_for ($game->{home_team}) / $hplyd );
    $points += ( $league->home_against ($game->{home_team}) / $hplyd );
    $points += ( $league->away_for ($game->{away_team}) / $aplyd );
    $points += ( $league->away_against ($game->{away_team}) / $aplyd );
    $points /= 2;

    push @ou_points, {
        home_team => $game->{home_team},
        away_team => $game->{away_team},
        points => $points,
    }
}

my @sorted = sort { $b->{points} <=> $a->{points} } @ou_points;
for my $game (@sorted) {
    print "\n$game->{home_team} v $game->{away_team} = $game->{points}";
}
