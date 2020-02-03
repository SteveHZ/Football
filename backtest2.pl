use MyHeader;
use MyTemplate;

use Football::Globals qw(@league_names @csv_leagues);
use Football::BackTest::FileList;
use Football::BackTest::Season;
use Football::BackTest::Game_Predictions;

my @my_data = ();
my $file_list = Football::BackTest::FileList->new (
    leagues => \@league_names,
    csv_leagues => \@csv_leagues,
    path => 'C:/Mine/perl/Football/data/historical',
    return_iterator => 1,
);
my $files = $file_list->get_historical;

my $season = Football::BackTest::Season->new (
    callback    => sub { do_predicts (@_) },
);

while (my $league = $files->()) {
    my $league_name = $league->{league_name};
    for my $file ($league->{file_info}->@*){
        $season->run ($league_name, $file);
    }
}

sub do_predicts {
	my ($game, $league) = @_;
    my $data = get_predicts ($game, $league);
#    push @my_data, $data;

#    say "$league->{name} - $game->{date} - $game->{home_team} v $game->{away_team} $game->{home_score}-$game->{away_score}";
#    say "home = $game->{home_goals} away = $game->{away_goals} expected goal diff = $game->{expected_goal_diff}";
#    say "home win = $data->{match_odds}->{home_win} away_win = $data->{match_odds}->{away_win} draw = $data->{match_odds}->{draw}";
#    say "over 2.5 = $data->{match_odds}->{over_2pt5} under 2.5 = $data->{match_odds}->{under_2pt5}";
#    <STDIN>;
}

sub write_data {
    my $tt = MyTemplate->new (filename => 'C:/Mine/perl/Football/data/backtest/E0.csv');
    my $out_fh = $tt->open_file ();

}
sub get_predicts {
	my ($game, $league) = @_;

    my $predict_model = Football::BackTest::Game_Predictions->new ();
#   $predict_model->calc_goal_expect ($game, $league),
    return {
        expect => $predict_model->calc_goal_expect ($game, $league),
        match_odds => $predict_model->calc_match_odds ($game),
    };
#        skellam => $predict_model->calc_skellam_dist (),
#        over_under => $predict_model->calc_over_under (),
}

#while (my $league = $files->()) {
#    for my $file ($league->{file_info}->@*){
##        say $file->{tag}. " = ".$file->{name};
#    }
#}
#die;

#my $season = Football::BackTest::Season->new (
#    files       => $files,
#    callback    => sub { do_predicts (@_) },
#);
#$season->run ();
#



=cut
