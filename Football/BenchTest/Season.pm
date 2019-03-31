package Football::BenchTest::Season;

use Football::Model;
use Football::Football_Data_Model;
use Football::Game_Prediction_Models;
use Football::BenchTest::Spreadsheets::BenchTest_View;
use Football::Utils qw(_get_all_teams);

use List::MoreUtils qw(each_arrayref);
use Moo;
use namespace::clean;

has 'models' => (is => 'ro', required => 1);
has 'files' => (is => 'ro', required => 1);
has 'func' => (is => 'ro', init_arg => 'callback', required => 1);

sub BUILD {
    my $self = shift;
    $self->{football_model} = Football::Model->new ();
    $self->{data_model} = Football::Football_Data_Model->new ();
}

sub run {
    my $self = shift;

    for my $league ( @{ $self->{files} }) {
        my ($league_name, $file_list) = each %$league;
        for my $file (@$file_list) {
            print "\nReading $file->{tag}...";
            my $games = $self->{data_model}->read_csv ($file->{name});

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
                    }
                }
                $league->update_teams ($league->teams, $game);
                $league->update_tables ($game);
            }
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

=pod

=head1 NAME

Football/BenchTest/Season.pm

=head1 SYNOPSIS

used by backtest.pl

=head1 DESCRIPTION

Read every line from CSV results file and call callback function on each game

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
