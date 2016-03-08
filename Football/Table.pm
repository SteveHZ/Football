package Football::Table;

# Football::Table.pm 15/02/16 - 07/03/16

use strict;
use warnings;

sub new {
	my ($class, $all_teams) = @_;

	my $self = {};
	for my $team (@$all_teams) {
		$self->{table}->{$team} = set_up_team ($team);
	}
	$self->{sorted} = [];

    bless $self, $class;
    return $self;
}

sub set_up_team {
	my $team = shift;
	return {
		team => $team,
		played => 0,
		won => 0,
		lost => 0,
		drawn => 0,
		for => 0,
		against => 0,
		points => 0,
		recent_goal_diff => [0,0,0,0,0,0],
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
	
	shift  @{ $self->{table}->{ $game->{home_team} }->{recent_goal_diff} };
	shift  @{ $self->{table}->{ $game->{away_team} }->{recent_goal_diff} };
	push ( @{ $self->{table}->{ $game->{home_team} }->{recent_goal_diff} }, $game->{home_score} - $game->{away_score} );
	push ( @{ $self->{table}->{ $game->{away_team} }->{recent_goal_diff} }, $game->{away_score} - $game->{home_score} );
}

sub sort_table {
	my $self = shift;
	my $table = $self->{table};

	$self->{sorted} = [];
	for my $team ( sort {
			$table->{$b}->{points} <=> $table->{$a}->{points}
			or _goal_diff ($table->{$b}) <=> _goal_diff ($table->{$a})
			or $table->{$b}->{for} <=> $table->{$a}->{for}
			or $table->{$a}->{team} cmp $table->{$b}->{team}
		} keys %{$table}) {
			push (@ {$self->{sorted} }, $table->{$team} );
	}
	return \@ {$self->{sorted} };
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

	my $total = 0;
	$total += $_ for (@ {$self->{table}->{$team}->{recent_goal_diff} } );
	return $total;
}

sub sorted 	{ my $self = shift; return \@ {$self->{sorted}} };

sub team	{ my $self = shift; return $self->{team} };
sub played	{ my $self = shift; return $self->{played} };
sub won		{ my $self = shift; return $self->{won} };
sub lost	{ my $self = shift; return $self->{lost} };
sub drawn	{ my $self = shift; return $self->{drawn} };
sub for		{ my $self = shift; return $self->{for} };
sub against	{ my $self = shift; return $self->{against} };
sub points	{ my $self = shift; return $self->{points} };

1;
