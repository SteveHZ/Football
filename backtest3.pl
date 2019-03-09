
#   backtest.pl 01-09/03/19

use strict;
use warnings;

use Football::Model;
use Football::League;
use Football::Globals qw(@league_names @csv_leagues);
use Football::Football_Data_Model;
use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Counter;
use Football::BenchTest::Spreadsheets::BenchTest_View;
use MyJSON qw(read_json);

use List::MoreUtils qw(each_array);
use Data::Dumper;

my $model = Football::Model->new ();
my $data_model = Football::Football_Data_Model->new ();
my $expect_model = Football::BenchTest::Goal_Expect_Model->new ();
my $counter = Football::BenchTest::Counter->new ();

my $path = 'C:/Mine/perl/Football/data/';
my $teams_file = $path.'teams.json';
my $teams = read_json ( $teams_file );

my $iterator = each_array (@league_names, @csv_leagues);
while (my ($league_name, $csv_league) = $iterator->()) {
print "\nReading $league_name...";
    my $csv_file = $path.$csv_league.'.csv';
    my $games = $data_model->read_csv ($csv_file);
    my $league = Football::League->new (
        name		=> $league_name,
        games 		=> $games,
        team_list	=> $teams->{$league_name},
        auto_build  => 0,
    );
    my $datafunc = $model->get_game_data_func ();
    my $flag = 0;

    for my $game (@$games) {
        $game->{league_idx} = 0;
#        print "\n$game->{home_team} v $game->{away_team} $game->{home_score}-$game->{away_score}";

        $league->{homes} = $league->do_homes ($league->teams);
        $league->{aways} = $league->do_aways ($league->teams);
        $league->{last_six} = $league->do_last_six ($league->teams);
        $datafunc->($game, $league);

        $league->update_teams ($league->teams, $game);
        $league->update_tables ($game);

        $flag = done_six_games ($game, $league) unless $flag;
        if ($flag) {
            my ($teams, $sorted) = do_predict_models ( [$game], [$league] );

            my $data = @{ $sorted->{expect} }[0];
            $counter->do_counts ($data);
        }
    }
}

#print Dumper $counter;

for (my $i = 0; $i <= 3; $i += 0.5) {
    print "\n\n$i:";
    print "\nHome Away : ".$counter->home_away_wins ($i). ' from '.$counter->home_away_games ($i). ' = '.($counter->home_away_wins ($i)/$counter->home_away_games ($i))*100;
    print "\nLast Six  : ".$counter->last_six_wins ($i). ' from '.$counter->last_six_games ($i). ' = '.($counter->last_six_wins ($i)/$counter->last_six_games ($i))*100;
    print "\nHa_lsx    : ".$counter->ha_lsx_wins ($i). ' from '.$counter->ha_lsx_games ($i). ' = '.($counter->ha_lsx_wins ($i)/$counter->ha_lsx_games ($i))*100;
}

my $bt_view = Football::BenchTest::Spreadsheets::BenchTest_View->new (filename => 'C:/Mine/perl/Football/reports/backtest.xlsx');
$bt_view->write ($counter);

sub do_predict_models {
	my ($fixtures, $leagues) = @_;
	my $predict_model = Football::Game_Prediction_Models->new (
		fixtures => $fixtures, leagues => $leagues);

	my ($teams, $sorted) = $predict_model->calc_goal_expect ();
	$sorted->{match_odds} = $predict_model->calc_match_odds ();
	$sorted->{skellam} = $predict_model->calc_skellam_dist ();
	$sorted->{over_under} = $predict_model->calc_over_under ();

#	$self->write_predictions ($fixtures);
	return ($teams, $sorted);
}

sub done_six_games {
    my ($game, $league) = @_;
    for my $team (@{ $league->team_list} ) {
        return 0 unless $league->{table}->played ( $game->{home_team} ) >= 6
                     && $league->{table}->played ( $game->{away_team} ) >= 6
    }
    return 1;
}
