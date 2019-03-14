package Football::BenchTest::Season;

use Football::Model;
use Football::Football_Data_Model;
use Football::Game_Prediction_Models;
#use Football::BenchTest::Counter;
use Football::BenchTest::Spreadsheets::BenchTest_View;
use MyJSON qw(read_json);

use List::MoreUtils qw(each_arrayref);
#use Data::Dumper;

use Moo;
use namespace::clean;

has 'models' => (is => 'ro');
has 'leagues' => (is => 'ro');
has 'csv_leagues' => (is => 'ro');

my $model = Football::Model->new ();
my $data_model = Football::Football_Data_Model->new ();

my $path = 'C:/Mine/perl/Football/data/';
my $teams_file = $path.'teams.json';
my $teams = read_json ( $teams_file );

sub run {
    my $self = shift;
    my $iterator = each_arrayref ($self->{leagues}, $self->{csv_leagues});
    while (my ($league_name, $csv_league) = $iterator->()) {
        print "\nReading $league_name...";
        my $csv_file = $path.$csv_league.'.csv';
        my $games = $data_model->read_csv ($csv_file);

        my $league = Football::League->new (
            name		=> $league_name,
            games 		=> [],
            team_list	=> $teams->{$league_name},
            auto_build  => 0,
        );
        my $datafunc = $model->get_game_data_func ();
        my $flag = 0;

        for my $game (@$games) {
            $game->{league_idx} = 0;
            $league->{homes} = $league->do_homes ($league->teams);
            $league->{aways} = $league->do_aways ($league->teams);
            $league->{last_six} = $league->do_last_six ($league->teams);
            $datafunc->($game, $league);
            $flag = done_six_games ($game, $league) unless $flag;

            if ($flag) {
                my ($teams, $sorted) = do_predict_models ($game, $league);
                my $data = @{ $sorted->{expect} }[0];

                for my $model (@{ $self->models }) {
                    $model->counter->do_counts ($data);
                }
            }
            $league->update_teams ($league->teams, $game);
            $league->update_tables ($game);
        }
    }
}

sub do_predict_models {
	my ($fixtures, $leagues) = @_;
	my $predict_model = Football::Game_Prediction_Models->new (
		fixtures => [ $fixtures ] , leagues => [ $leagues ] );

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

1;

=head
#my @csv_leagues = qw(E0 E1);
#my @league_names = ('Premier League','Championship');
#my @win_data = ();

#            push @win_data, {
#                home_team => $data->{home_team},
#                away_team => $data->{away_team},
#                home_score => $data->{home_score},
#                away_score => $data->{away_score},
#                goals => $data->{home_score} + $data->{away_score},
#                ou_points => $data->{ou_points},
#            };
#write_csv (\@win_data);


#sub write_csv {
#    my $data = shift;
#    open my $fh, '>','c:/mine/perl/football/reports/windata.csv' or die 'cant open file';
#    print "\nC:/Mine/perl/Football/reports/windata.csv...";
#    print $fh "Home,Away,H,A,TG,OU";
#    for my $line (@$data) {
#        print $fh "\n$line->{home_team}, $line->{away_team}, $line->{home_score}, $line->{away_score}, $line->{goals}, $line->{ou_points}";
#    }
#    close $fh;
#}
=cut
