package Football::Team_Hash;

use Football::Team_Profit;
use Football::Utils qw(_get_all_teams);
use Football::Model;

use Keyword::DEVELOPMENT;
DEVELOPMENT { use Data::Dumper; }

use Mu;
use namespace::clean;

ro 'func', default => sub {};
ro 'fixtures', default => sub { [] };

ro 'hash', default => sub { {} };
ro 'teams', default => sub { [] };
ro 'min_profit', default => 0.50;
ro 'min_win_rate', default => 0.50;

sub BUILD {
	my $self = shift;

	$self->{sheetnames} = [ "totals", "all homes", "all aways", "homes", "aways" ];
	$self->{dispatch} = {
		'totals'	=> \&Football::Team_Hash::sort_totals,
		'all homes'	=> \&Football::Team_Hash::sort_all_homes,
		'all aways'	=> \&Football::Team_Hash::sort_all_aways,
		'homes'		=> \&Football::Team_Hash::sort_homes,
		'aways'		=> \&Football::Team_Hash::sort_aways,
	};
}

sub team {
	my ($self, $team) = @_;
	return $self->{hash}->{$team};
}

sub add_teams {
	my ($self, $results, $lg_idx) = @_;

	my $teams = _get_all_teams ($results, 'home_team');
	for my $team (@$teams) {
		$self->{hash}->{$team} = Football::Team_Profit->new (team => $team);
		$self->{hash}->{$team}->{lg_idx} = $lg_idx;
		push (@{ $self->{teams} }, $team);
	}
}

sub place_stakes {
	my ($self, $home_team, $away_team) = @_;
	$self->{hash}->{$home_team}->home_staked ();
	$self->{hash}->{$away_team}->away_staked ();
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

	for my $sheetname ( @{ $self->{sheetnames} } ) {
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
		} @{ $self->{teams} }
	];
}

sub sort_all_homes {
	my $self = shift;
	return [
		sort {
			$self->home ($b) <=> $self->home ($a)
			or $a cmp $b
		} @{ $self->{teams} }
	];
}

sub sort_all_aways {
	my $self = shift;
	return [
		sort {
			$self->away ($b) <=> $self->away ($a)
			or $a cmp $b
		} @{ $self->{teams} }
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
		@{ $self->{fixtures} }
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
		@{ $self->{fixtures} }
	];
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
