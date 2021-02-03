package Football::Table;

# 	Football::Table.pm 15/02/16 - 07/03/16, Mouse version 04/05/16
#	Moo version 01/10/16

use List::Util qw(sum);
use Moo;
use namespace::clean;

has 'table' => ( is => 'ro' );
has 'sorted' => ( is => 'ro' );

sub BUILD {
	my ($self, $args) = @_;

	for my $team ($args->{teams}->@*) {
		$self->{table}->{$team} = set_up_team ($team);
	}
}

sub set_up_team {
	my $team = shift;
	return {
		team => $team,
		position => 0,
		played => 0,
		won => 0,
		lost => 0,
		drawn => 0,
		for => 0,
		against => 0,
		points => 0,
		recent_goal_diff => 0,
		rgd_list => [0,0,0,0,0,0],
	};
}

sub update {
	my ($self, $game) = @_;

	$self->do_played ($game);
	if ( $game->{home_score} > $game->{away_score} ) {
		$self->do_home_win ($game);
	} elsif ( $game->{away_score} > $game->{home_score} ) {
		$self->do_away_win ($game);
	} else {
		$self->do_draw ($game);
	}
	$self->do_goals ($game);
	$self->do_recent_goal_diff ($game);
}

sub do_played {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{played} ++;
	$self->{table}->{ $game->{away_team} }->{played} ++;
}

sub do_home_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{won} ++;
	$self->{table}->{ $game->{home_team} }->{points} += 3;
	$self->{table}->{ $game->{away_team} }->{lost} ++;
}

sub do_away_win {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{away_team} }->{won} ++;
	$self->{table}->{ $game->{away_team} }->{points} += 3;
	$self->{table}->{ $game->{home_team} }->{lost} ++;
}

sub do_draw {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{drawn} ++;
	$self->{table}->{ $game->{away_team} }->{drawn} ++;
	$self->{table}->{ $game->{home_team} }->{points} ++;
	$self->{table}->{ $game->{away_team} }->{points} ++;
}

sub do_goals {
	my ($self, $game) = @_;
	$self->{table}->{ $game->{home_team} }->{for} += $game->{home_score};
	$self->{table}->{ $game->{away_team} }->{for} += $game->{away_score};
	$self->{table}->{ $game->{home_team} }->{against} += $game->{away_score};
	$self->{table}->{ $game->{away_team} }->{against} += $game->{home_score};
}

sub do_recent_goal_diff {
	my ($self, $game) = @_;

	shift  $self->{table}->{ $game->{home_team} }->{rgd_list}->@*;
	shift  $self->{table}->{ $game->{away_team} }->{rgd_list}->@*;
	push   $self->{table}->{ $game->{home_team} }->{rgd_list}->@*, $game->{home_score} - $game->{away_score};
	push   $self->{table}->{ $game->{away_team} }->{rgd_list}->@*, $game->{away_score} - $game->{home_score};
}

sub sort_table {
	my $self = shift;
	my $table = $self->{table};
	my $idx = 1;

	$self->{sorted} = [
		map  {
			$table->{$_}->{position} = $idx++;
			$table->{$_}->{recent_goal_diff} = sum $table->{$_}->{rgd_list}->@*;
 			$table->{$_};
		}
		sort {
			$table->{$b}->{points} <=> $table->{$a}->{points}
			or _goal_diff ($table->{$b}) <=> _goal_diff ($table->{$a})
			or $table->{$b}->{for} <=> $table->{$a}->{for}
			or $table->{$a}->{team} cmp $table->{$b}->{team}
		}
		keys %$table
	];
}

sub _goal_diff {
	my $team = shift;
	return $team->{for} - $team->{against};
}

sub goal_diff {
	my ($self, $team) = @_;
	return $self->{table}->{$team}->{for} - $self->{table}->{$team}->{against};
}

sub recent_goal_diff {
	my ($self, $team) = @_;
	return $self->{table}->{$team}->{recent_goal_diff};
}

sub calc_goal_difference {
	my ($self, $games) = @_;

	my $total = 0;
	for my $game (@$games) {
		if ($game->{score} =~ /(\d+)-(\d+)/) {
			$total += ($1 - $2) ;
		}
	}
	return $total;
}

sub check_for_zero_games {
	my $self = shift;

	for my $team (keys %$self) {
		return 1 if $self->played ($team) == 0;
	}
	return 0;
}

sub _get {
	my ($self, $team, $data) = @_;
	return $self->{table}->{$team}->{$data};
}

sub position { my ($self, $team) = @_; return $self->_get ($team, 'position'); };
sub played	 { my ($self, $team) = @_; return $self->_get ($team, 'played'); };
sub won		 { my ($self, $team) = @_; return $self->_get ($team, 'won'); }
sub lost 	 { my ($self, $team) = @_; return $self->_get ($team, 'lost'); }
sub drawn 	 { my ($self, $team) = @_; return $self->_get ($team, 'drawn'); }
sub for 	 { my ($self, $team) = @_; return $self->_get ($team, 'for'); }
sub against  { my ($self, $team) = @_; return $self->_get ($team, 'against'); }
sub points 	 { my ($self, $team) = @_; return $self->_get ($team, 'points'); }

=begin comment

sub get_data {
	my $self = shift;
	return sub {
		my ($team, $data) = @_;
		return $self->{table}->{$team}->{$data};
	}
}

sub played	{ my ($self, $team) = @_; return $self->get_data->($team, 'played'); };
sub won		{ my ($self, $team) = @_; return $self->get_data->($team, 'won'); }
sub lost 	{ my ($self, $team) = @_; return $self->get_data->($team, 'lost'); }
sub drawn 	{ my ($self, $team) = @_; return $self->get_data->($team, 'drawn'); }
sub for 	{ my ($self, $team) = @_; return $self->get_data->($team, 'for'); }
sub against { my ($self, $team) = @_; return $self->get_data->($team, 'against'); }
sub points 	{ my ($self, $team) = @_; return $self->get_data->($team, 'points'); }

=end comment
=cut

=pod

=head1 NAME

Table.pm

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
