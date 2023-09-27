#   create_backtest.pl 02-15/02/20, 23/02/23

use MyHeader;
use MyTemplate;

use Football::Globals qw(@league_names @csv_leagues);
use Football::BackTest::FileList;
use Football::BackTest::Season;
use Football::BackTest::Season_Predictions;
use Football::BackTest::Recent_Predictions;

#my $start_year = 2015;  # for testing, earlier files don't have all fields

my $season = Football::BackTest::Season->new (
    callback => sub { do_predicts (@_) },
);

my $file_list = Football::BackTest::FileList->new (
    leagues => \@league_names,
    csv_leagues => \@csv_leagues,
    path => 'C:/Mine/perl/Football/data',
    func => sub {
        my $filename = shift;
        return 1 if $filename =~ /\.csv$/;
        return 0;
    },
);

my $files_iterator = $file_list->get_current_as_iterator;

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

    my $season_model = Football::BackTest::Season_Predictions->new ();
    my $recent_model = Football::BackTest::Recent_Predictions->new ();
    $season_model->calc_goal_expect ($game, $league),
    $recent_model->calc_goal_expect ($game, $league),

    return {
        season_match_odds => $season_model->calc_match_odds ($game),
		recent_match_odds => $recent_model->calc_match_odds ($game),
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

        season_home_expect => sprintf ("%.2f", $game->{home_goals}),
        season_away_expect => sprintf ("%.2f", $game->{away_goals}),
        season_home_win => $data->{season_match_odds}->{home_win},
        season_away_win => $data->{season_match_odds}->{away_win},
        season_draw => $data->{season_match_odds}->{draw},
        season_over_2pt5 => $data->{season_match_odds}->{over_2pt5},
        season_under_2pt5 => $data->{season_match_odds}->{under_2pt5},

        recent_home_expect => sprintf ("%.2f", $game->{home_last_six}),
        recent_away_expect => sprintf ("%.2f", $game->{away_last_six}),
        recent_home_win => $data->{recent_match_odds}->{home_win},
        recent_away_win => $data->{recent_match_odds}->{away_win},
        recent_draw => $data->{recent_match_odds}->{draw},
        recent_over_2pt5 => $data->{recent_match_odds}->{over_2pt5},
        recent_under_2pt5 => $data->{recent_match_odds}->{under_2pt5},

        b365h => $game->{b365h},
        b365a => $game->{b365a},
        b365d => $game->{b365d},
        b365over => $game->{av_over},
        b365under => $game->{av_under},
    };
}

sub write_data {
    my ($data, $league_name) = @_;

    say "\nWriting $league_name...";
    my $tt = MyTemplate->new (
		filename => "C:/Mine/perl/Football/data/backtest/$league_name.csv",
		template => 'Template/backtest.tt',
		data => $data,
	);
    
	$tt->write_file ();
}
