package Football::BenchTest::Season;

use Football::Model;
use Football::Football_Data_Model;
use Football::Game_Prediction_Models;
use Football::BenchTest::Spreadsheets::BenchTest_View;
use Football::Utils qw(_get_all_teams);
use MyJSON qw(read_json);

use List::MoreUtils qw(each_arrayref);
#use Data::Dumper;

use Moo;
use namespace::clean;

has 'models' => (is => 'ro');
has 'leagues' => (is => 'ro');
has 'csv_leagues' => (is => 'ro');
#maybe have a file list passed in instead ??
has 'path' => (is => 'ro', default => 'C:/Mine/perl/Football/data/');
has 'func' => (is => 'ro', init_arg => 'callback', required => 1);

sub BUILD {
    my $self = shift;
    $self->{football_model} = Football::Model->new ();
    $self->{data_model} = Football::Football_Data_Model->new ();
}

sub run {
    my $self = shift;
    my $iterator = each_arrayref ($self->{leagues}, $self->{csv_leagues});
    while (my ($league_name, $csv_league) = $iterator->()) {
        print "\nReading $league_name...";
        my $csv_file = $self->{path}.$csv_league.'.csv';
        my $games = $self->{data_model}->read_csv ($csv_file);

        my $league = Football::League->new (
            name		=> $league_name,
            games 		=> [],
            team_list	=> _get_all_teams ($games, 'home_team'),
            auto_build  => 0,
        );
        my $datafunc = $self->{football_model}->get_game_data_func ();
        my $flag = 0;

        for my $game (@$games) {
            $game->{league_idx} = 0;
            $league->{homes} = $league->do_homes ($league->teams);
            $league->{aways} = $league->do_aways ($league->teams);
            $league->{last_six} = $league->do_last_six ($league->teams);
            $flag = done_six_games ($game, $league) unless $flag;

            if ($flag) {
                $datafunc->($game, $league);
                my $data = $self->func->($self, $game, $league);
                for my $model (@{ $self->models }) {
                    $model->do_counts ($data);
#                    $model->counter->do_counts ($data);
                }
            }
            $league->update_teams ($league->teams, $game);
            $league->update_tables ($game);
        }
    }
}

sub done_six_games {
    my ($game, $league) = @_;
    for my $team (@{ $league->team_list} ) {
        return 0 unless $league->{table}->played ($team) >= 6;
    }
    return 1;
}

1;
