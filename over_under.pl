#   26/01/20

use MyHeader;
use Football::Model;

my $model = Football::Model->new ();
my ($data, $stats) = $model->quick_build ();
my $iterator = $model->iterate_stats_by_league ($stats);
my @list;

while (my $league = $iterator->()) {
    print "\n$league->{league}";
    for my $game ( $league->{games}->@* ) {
        my $home = get_overs ($game->{full_homes});
        my $away = get_overs ($game->{full_aways});
        push @list, {
            home_team => $game->{home_team},
            away_team => $game->{away_team},
            odds => get_odds ($home, $away),
        };
    }
}

my @sorted = sort { $a->{odds} <=> $b->{odds} } @list;
for my $game (@sorted) {
    print "\n$game->{odds} - $game->{home_team} v $game->{away_team}";
}

sub get_odds {
    my ($home, $away) = @_;
    return make_odds (($home + $away) / 12);
}

sub make_odds {
    my $p = shift;
    return 'Inf' if $p == 0;
    return sprintf "%0.2f", (1 / $p);
}

sub get_overs {
    my $games = shift;
    my $count = 0;
    for my $game (@$games) {
        $count ++ if is_over ($game);
    }
    return $count;
}

sub is_over ($game, $ou_goals = 2.5) {
    my ($home, $away) = split '-', $game->{score};
    return 1 if $home + $away > $ou_goals;
    return 0;
}

=head
for my $league ($stats->{by_league}->@*) {
    for my $game ($league->{games}->@*) {
        print "\n$game->{home_team} - ". get_overs ($game->{full_homes}) . "-". get_overs ($game->{full_home_last_six});
        print "  $game->{away_team} - ". get_overs ($game->{full_aways}) . "-". get_overs ($game->{full_away_last_six});
        print "\nOdds = ".get_odds (get_overs ($game->{full_homes}), get_overs ($game->{full_aways}));
    }
}
my $o = make_odds ($p);
my $p = 72.69;
print "\n$p - $o";

for my $h (0..6) {
    for my $a (0..6) {
        my $prob = ($h + $a) / 12;
        print "\n $h - $a = ". make_odds ($prob);
    }
}
my $predict_model = Football::Game_Predictions::Model->new (
	leagues => $data->{leagues},
	fixtures => $stats->{by_match},
);

my $expect_model = Football::Game_Predictions::Goal_Expect_Model->new (
	leagues => $data->{leagues},
	fixtures => $stats->{by_match},
);
say "ok";
=cut
