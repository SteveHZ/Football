package Football::HomeTable;

#	Football::HomeTable.pm 17/02/16
#	Mouse version 04/05/16
#	Moo version 01/10/16

use Moo;
use namespace::clean;

extends 'Football::Table';

sub do_played {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{played} ++;
}

sub do_home_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{won} ++;
	$self->{table}->{ $game->{home_team} }->{points} += 3;
}

sub do_away_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{lost} ++;
}

sub do_draw {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{drawn} ++;
	$self->{table}->{ $game->{home_team} }->{points} ++;
}

sub do_goals {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{for} += $game->{home_score};
	$self->{table}->{ $game->{home_team} }->{against} += $game->{away_score};
}

sub home_position { my ($self, $team) = @_; return $self->_get ($team, 'position'); };
sub home_played	{ my ($self, $team) = @_; return $self->_get ($team, 'played'); };
sub home_won		{ my ($self, $team) = @_; return $self->_get ($team, 'won'); }
sub home_lost 	{ my ($self, $team) = @_; return $self->_get ($team, 'lost'); }
sub home_drawn 	{ my ($self, $team) = @_; return $self->_get ($team, 'drawn'); }
sub home_for 	{ my ($self, $team) = @_; return $self->_get ($team, 'for'); }
sub home_against { my ($self, $team) = @_; return $self->_get ($team, 'against'); }
sub home_points 	{ my ($self, $team) = @_; return $self->_get ($team, 'points'); }

=pod

=head1 NAME

HomeTable.pm

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
