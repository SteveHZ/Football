package Football::Team_Hash;

use Football::Team_Profit;
use Football::Model;

use MyKeyword qw(DEVELOPMENT);
DEVELOPMENT { use Data::Dumper; }

use Mu;
use namespace::clean;

ro 'fixtures', default => sub { [] };
ro 'hash', default => sub { {} };
ro 'teams', default => sub { [] };
ro 'min_profit', default => 0.50;
ro 'min_win_rate', default => 0.50;
ro 'leagues' , default => sub { [] };

sub BUILD {
	my $self = shift;

	$self->{sheetnames} = [ "totals", "all homes", "all aways", "homes", "aways" ];
	$self->{dispatch} = {
		'totals'	=> sub { my $self = shift; $self->sort_totals () },
		'all homes'	=> sub { my $self = shift; $self->sort_all_homes () },
		'all aways'	=> sub { my $self = shift; $self->sort_all_aways () },
		'homes'		=> sub { my $self = shift; $self->sort_homes () },
		'aways'		=> sub { my $self = shift; $self->sort_aways () },
	};
}

sub team {
	my ($self, $team) = @_;
	return $self->{hash}->{$team};
}

sub add_teams {
	my ($self, $results, $teams, $lg_idx) = @_;

	for my $team (@$teams) {
		$self->{hash}->{$team} = Football::Team_Profit->new (team => $team);
		$self->{hash}->{$team}->{lg_idx} = $lg_idx;
		push $self->{teams}->@*, $team;
	}
}

sub add_teams6 {
	my ($self, $teams, $lg_idx) = @_;
	$lg_idx //= 0;

	for my $team (@$teams) {
		$self->{hash}->{$team} = Football::Team_Profit->new (team => $team);
		$self->{hash}->{$team}->{lg_idx} = $lg_idx;
		push $self->{teams}->@*, $team;
	}
}

sub place_stakes {
	my ($self, $game) = @_;
	DEVELOPMENT { print "\n$game->{home_team} v $game->{away_team}"; }
	strip_team_names ($game);
	$self->{hash}->{$game->{home_team}}->home_staked ();
	$self->{hash}->{$game->{away_team}}->away_staked ();
}

sub home_win {
	my ($self, $team, $amount) = @_;
	DEVELOPMENT { print "\nHome : $team - $amount"; }
	$self->{hash}->{$team}->{home} += $amount;
	$self->{hash}->{$team}->{total} += $amount;
	$self->{hash}->{$team}->{home_win} ++;
}

sub away_win {
	my ($self, $team, $amount) = @_;
	DEVELOPMENT { print "\nAway : $team - $amount"; }
	$self->{hash}->{$team}->{away} += $amount;
	$self->{hash}->{$team}->{total} += $amount;
	$self->{hash}->{$team}->{away_win} ++;
}

sub percent {
	my ($self, $team) = @_;
	return $self->{hash}->{$team}->percent ();
}

sub home {
	my ($self, $team) = @_;
	return $self->{hash}->{$team}->home_percent ();
}

sub away {
	my ($self, $team) = @_;
	return $self->{hash}->{$team}->away_percent ();
}

sub home_win_rate {
	my ($self, $team) = @_;
	return $self->{hash}->{$team}->home_win_rate ();
}

sub away_win_rate {
	my ($self, $team) = @_;
	return $self->{hash}->{$team}->away_win_rate ();
}

sub sort {
	my $self = shift;
	my %hash = ();

	for my $sheetname ($self->{sheetnames}->@*) {
		$hash{$sheetname} = $self->{dispatch}->{ $sheetname }->($self);
	}
	return \%hash;
}

#	called from sort as arguments to $self->{dispatch}

sub sort_totals {
	my $self = shift;
	return [
		sort {
			$self->percent ($b) <=> $self->percent ($a)
			or $a cmp $b
		} $self->{teams}->@*
	];
}

sub sort_all_homes {
	my $self = shift;
	return [
		sort {
			$self->home ($b) <=> $self->home ($a)
			or $a cmp $b
		} $self->{teams}->@*
	];
}

sub sort_all_aways {
	my $self = shift;
	return [
		sort {
			$self->away ($b) <=> $self->away ($a)
			or $a cmp $b
		} $self->{teams}->@*
	];
}

sub sort_homes {
	my $self = shift;

	return [
		sort {
			$self->home ($b) <=> $self->home ($a)
			or $a cmp $b
		}
		grep {
			$self->home ($_) >= $self->{min_profit}
		 	&& $self->home_win_rate ($_) >= $self->{min_win_rate}
		}
		map  { $_->{home_team} }
		$self->{fixtures}->@*
	];
}

sub sort_aways {
	my $self = shift;

	return [
		sort {
			$self->away ($b) <=> $self->away ($a)
			or $a cmp $b
		}
		grep {
			$self->away ($_) >= $self->{min_profit}
		 	&& $self->away_win_rate ($_) >= $self->{min_win_rate}
		}
		map  { $_->{away_team} }
		$self->{fixtures}->@*
	];
}

sub get_combine_file_data {
	my ($self, $sorted_hash) = @_;
	my %sorted = (
		homes => $sorted_hash->{homes},
		aways => $sorted_hash->{aways}
	);
	my $dispatch = {
		'homes'		=> sub { $self->get_homes (@_) },
		'aways'		=> sub { $self->get_aways (@_) },
	};
	my %hash = ();

	for my $key (keys %sorted) {
		my @data = ();
		for my $team ($sorted{$key}->@*) {
			push @data, $dispatch->{$key}->($team);
		}
		$hash{$key} = \@data;
	}
	return \%hash;
}

sub get_homes {
	my ($self, $team) = @_;

	return [
		$self->{leagues}->[ $self->{hash}->{$team}->{lg_idx} ],
		$team,
		$self->{hash}->{$team}->home_stake,
		$self->{hash}->{$team}->home,
		$self->{hash}->{$team}->away,
		$self->{hash}->{$team}->total,
		$self->{hash}->{$team}->home_percent,
		$self->{hash}->{$team}->home_win_rate,
	];
}

sub get_aways {
	my ($self, $team) = @_;
	return [
		$self->{leagues}->[ $self->{hash}->{$team}->{lg_idx} ],
		$team,
		$self->{hash}->{$team}->away_stake,
		$self->{hash}->{$team}->home,
		$self->{hash}->{$team}->away,
		$self->{hash}->{$team}->total,
		$self->{hash}->{$team}->away_percent,
		$self->{hash}->{$team}->away_win_rate,
	];
}

# strip apostrophe from Nott'm Forest etc
sub strip_team_names {
	my $game = shift;
	$game->{home_team} =~ s/'//;
	$game->{away_team} =~ s/'//;
}

=pod

=head1 NAME

Team_Hash.pm

=head1 SYNOPSIS

Used by max_profit.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
