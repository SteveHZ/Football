#   26/01/20
use MyHeader;
use Football::Model;
#use Football::Game_Predictions::Model;
#use Football::Game_Predictions::Goal_Expect_Model;

#=head
my $model = Football::Model->new ();
my ($data, $stats) = $model->quick_build ();
my @list;

sub iterate_stats_by_league {
    my $stats = shift;
    my $size = scalar $stats->{by_league}->@*;
    my $index = 0;

    return sub {
        return undef if $index == $size;
        return $stats->{by_league}->[$index++]->{games};
    }
}

#for my $league ($stats->{by_league}->@*) {
#    for my $game ($league->{games}->@*) {
my $iterator = iterate_stats_by_league ($stats);
while (my $games = $iterator->()) {
    for my $game (@$games) {
        my $home = get_overs ($game->{full_homes});
        my $away = get_overs ($game->{full_aways});
        push @list, {
            home_team => $game->{home_team},
            away_team => $game->{away_team},
            odds => get_odds ($home, $away),
        };
#        print "\n$game->{home_team} - ". get_overs ($game->{full_homes}) . "-". get_overs ($game->{full_home_last_six});
#        print "  $game->{away_team} - ". get_overs ($game->{full_aways}) . "-". get_overs ($game->{full_away_last_six});
#        print "\nOdds = ".get_odds (get_overs ($game->{full_homes}), get_overs ($game->{full_aways}));
    }
}

my @sorted = sort { $a->{odds} <=> $b->{odds} } @list;
for my $game (@sorted) {
    print "\n$game->{odds} - $game->{home_team} v $game->{away_team}";
}

=head
my $o = make_odds ($p);
my $p = 72.69;
print "\n$p - $o";

for my $h (0..6) {
    for my $a (0..6) {
        my $prob = ($h + $a) / 12;
        print "\n $h - $a = ". make_odds ($prob);
    }
}
=cut

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

#die;

=head
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
#die;



=head
subtest 'Constructors' => sub {
	plan 3;
	isa_ok ($model, ['Football::Model'], '$model');
	isa_ok ($predict_model, ['Football::Game_Predictions::Model'], '$predict_model');
	isa_ok ($expect_model, ['Football::Game_Predictions::Goal_Expect_Model'], '$expect_model');
};

subtest 'get_average' => sub {
	plan 1;
	my $list = [ qw( Stoke Vale Crewe Leek ) ];
	is ($expect_model->get_average (24, $list), '6.00', 'get_average');
};

subtest 'goal_expect' => sub {
	plan 12;
	my ($teams, $sorted) = $predict_model->calc_goal_expect ();

	is ($teams->{Stoke}->{av_home_for}, 1.33, 'av home for');
	is ($teams->{Stoke}->{av_home_against}, 1.83, 'av home against');
	is ($teams->{Stoke}->{av_away_for}, 1.17, 'av away for');
	is ($teams->{Stoke}->{av_away_against}, 2.17, 'av away against');

	is ($teams->{Stoke}->{expect_home_for}, '0.90', 'expect home for');
	is ($teams->{Stoke}->{expect_home_against}, 1.61, 'expect home against');
	is ($teams->{Stoke}->{expect_away_for}, 1.03, 'expect away for');
	is ($teams->{Stoke}->{expect_away_against}, 1.47, 'expect away against');

	is ($teams->{Stoke}->{last_six_for}, 10, 'last_six for');
	is ($teams->{Stoke}->{last_six_against}, 14, 'last_six against');
	is ($teams->{Stoke}->{av_last_six_for}, 1.66666666666667, 'av last_six for');
	is ($teams->{Stoke}->{av_last_six_against}, 2.33333333333333, 'av last_six against');
};
=cut
