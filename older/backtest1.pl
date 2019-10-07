
#   backtest.pl 01/03/19

use strict;
use warnings;

use Football::Model;
use Football::Football_Data_Model;
use Football::League;
#use Football::View;
use Data::Dumper;
use MyJSON qw(read_json);

my $path = 'C:/Mine/perl/Football/data/';
my $teams_file = $path.'teams.json';
my $csv_file = $path.'E0.csv';
#my $csv_file = $ARGV[0] or die "No csv file !";

my $model = Football::Model->new ();
my $data_model = Football::Football_Data_Model->new ();
my $games = $data_model->read_csv ($csv_file);

my $teams = read_json ( $teams_file );
my $league = Football::League->new (
    name		=> 'Premier League',
    games 		=> $games,
    team_list	=> $teams->{'Premier League'},
    auto_build  => 0,
);
$league->{home_table} = $league->create_new_home_table ();
$league->{away_table} = $league->create_new_away_table ();
my $datafunc = $model->get_game_data_func ();
my $flag = 0;
my $played = 0;
my $ha_wins = 0;

for my $game (@$games) {
    $game->{league_idx} = 0;
print Dumper $game unless $flag;
    $league->{homes} = $league->do_homes ($league->teams);
    $league->{aways} = $league->do_aways ($league->teams);
    $league->{last_six} = $league->do_last_six ($league->teams);
    $datafunc->($game, $league);
#print Dumper $game;

#<STDIN>;
    $league->update_teams ($league->teams, $game);
    $league->table->update ($game);
    $league->table->sort_table ();
    $league->home_table->update ($game);
    $league->away_table->update ($game);
    $flag = done_six_games ($game, $league) unless $flag;
#    if (! $flag) {
#        $flag = done_six_games ($game, $league);
#    }
    if ($flag) {
        $played ++;
#        do_table ($league);
#       <STDIN>;
        my ($teams, $sorted) = do_predict_models (undef, [$game],[$league]);
#<STDIN>;
#print Dumper $teams;

#<STDIN>;
#print Dumper $sorted->{expect};
        my $expect = @{ $sorted->{expect} }[0];
        print "\n\n$game->{home_team} v $game->{away_team} $game->{home_score}-$game->{away_score}";
        print "\nhome = $expect->{home_goals} away = $expect->{away_goals} diff = $expect->{expected_goal_diff}";
        $ha_wins ++ if ($expect->{home_score} > $expect->{away_score} && $expect->{expected_goal_diff} > 0 )
                    or ($expect->{away_score} > $expect->{home_score} && $expect->{expected_goal_diff} < 0 )
#    print Dumper $league->table;
#    <STDIN>;
    }
}
print "\n\n$ha_wins wins from $played played";

sub do_predict_models {
	my ($self, $fixtures, $leagues) = @_;
#print Dumper $fixtures;<STDIN>;
#print Dumper @$leagues[0]->home_table;<STDIN>;
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
        return 0 unless $league->{table}->played ( $game->{home_team} ) > 6
                     && $league->{table}->played ( $game->{away_team} ) > 6
    }
    return 1;
}

sub do_table {
    my $league = shift;
	my $league_name = $league->{name};
	my $table = $league->table->sorted;

	print "\n\n$league_name Full Table : \n\n";
    printf "%21s %2s %2s %2s %3s %3s %3s %2s", @{[ qw (P W L D F A GD Pts) ]};

	for my $team (@$table) {
		printf "\n%-18s %2d %2d %2d %2d %3d %3d %3d %3d",
			$team->{team}, $team->{played}, $team->{won}, $team->{lost},
			$team->{drawn}, $team->{for}, $team->{against},
			$team->{for} - $team->{against},
			$team->{points};
	}
	print "\n";
}
