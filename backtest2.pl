#   backtest2.pl 02-15/02/20

use MyHeader;
use MyTemplate;

use Football::Globals qw(@league_names @csv_leagues);
use Football::BackTest::FileList;
use Football::BackTest::Season;
use Football::BackTest::Game_Predictions;

my $season = Football::BackTest::Season->new (
    callback => sub { do_predicts (@_) },
);

my $file_list = Football::BackTest::FileList->new (
    leagues => \@league_names,
    csv_leagues => \@csv_leagues,
    path => 'C:/Mine/perl/Football/data/historical',
    func => sub {
        my $filename = shift;
        return 1 if $filename =~ /\.csv$/ && substr ($filename, 0, -4) >= 2005; # earlier files don't have all fields
        return 0;
    },
);

my $files_iterator = $file_list->get_historical_as_iterator;
while (my $league = $files_iterator->()) {
    my $league_name = $league->{league_name};
    my $my_data = [];
    for my $file ( $league->{file_info}->@* ) {
        $season->run ($league_name, $file, $my_data);
    }
    write_data ($my_data, $league_name);
}

sub do_predicts {
	my ($league, $game, $my_data) = @_;
    my $data = get_predicts ($league, $game);
    my $dd = get_data ($league, $game, $data);
    push @$my_data, get_data ($league, $game, $data);
}

sub get_predicts {
	my ($league, $game) = @_;

    my $predict_model = Football::BackTest::Game_Predictions->new ();
    return {
        expect => $predict_model->calc_goal_expect ($game, $league),
        match_odds => $predict_model->calc_match_odds ($game),
    };
}

sub get_data {
    my ($league, $game, $data) = @_;
    return {
        league => $league->{name},
        date => $game->{date},
        home_team => $game->{home_team},
        away_team => $game->{away_team},
        home_score => $game->{home_score},
        away_score => $game->{away_score},
        result => $game->{result},
        home_expect => $data->{expect}->{$game->{home_team}}->{expect_home_for},
        away_expect => $data->{expect}->{$game->{away_team}}->{expect_away_for},
        home_win => $data->{match_odds}->{home_win},
        away_win => $data->{match_odds}->{away_win},
        draw => $data->{match_odds}->{draw},
        over_2pt5 => $data->{match_odds}->{over_2pt5},
        under_2pt5 => $data->{match_odds}->{under_2pt5},
        b365h => $game->{b365h},
        b365a => $game->{b365a},
        b365d => $game->{b365d},
        b365over => $game->{b365over},
        b365under => $game->{b365under},
    };
}

sub write_data {
    my ($data, $league_name) = @_;

    say "\nWriting $league_name...";
    my $tt = MyTemplate->new (filename => "C:/Mine/perl/Football/data/backtest/$league_name.csv");
    my $out_fh = $tt->open_file ();

    $tt->process ('Template/backtest.tt', {
        data => $data,
    }, $out_fh) or die $tt->error;
}
