package Football::AwayTable;

#	Football::AwayTable.pm 17/02/16
#	Mouse version 04/05/16
#	Moo version 01/10/16

use Moo;
use namespace::clean;

extends 'Football::Table';

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

sub away_position { my ($self, $team) = @_; return $self->_get ($team, 'position'); };
sub away_played	{ my ($self, $team) = @_; return $self->_get ($team, 'played'); };
sub away_won		{ my ($self, $team) = @_; return $self->_get ($team, 'won'); }
sub away_lost 	{ my ($self, $team) = @_; return $self->_get ($team, 'lost'); }
sub away_drawn 	{ my ($self, $team) = @_; return $self->_get ($team, 'drawn'); }
sub away_for 	{ my ($self, $team) = @_; return $self->_get ($team, 'for'); }
sub away_against { my ($self, $team) = @_; return $self->_get ($team, 'against'); }
sub away_points 	{ my ($self, $team) = @_; return $self->_get ($team, 'points'); }

=pod

=head1 NAME

AwayTable.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
