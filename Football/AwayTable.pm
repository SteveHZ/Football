package Football::AwayTable;

# Football::AwayTable.pm 17/02/16

use strict;
use warnings;

use parent 'Football::Table';

sub new {
	my ($class, $all_teams) = @_;

	my $self = $class->SUPER::new ($all_teams);
    bless $self, $class;
    return $self;
}

sub do_played {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{played} ++;
}

sub do_home_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{lost} ++;
}

sub do_away_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{won} ++;
	$self->{table}->{ $game->{away_team} }->{points} += 3;
}

sub do_draw {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{drawn} ++;
	$self->{table}->{ $game->{away_team} }->{points} ++;
}

sub do_goals {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{for} += $game->{away_score};
	$self->{table}->{ $game->{away_team} }->{against} += $game->{home_score};
}

1;
