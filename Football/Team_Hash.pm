package Football::Team_Hash;

use Moo;
use namespace::clean;

use Football::Team_Profit;
use Football::Utils qw(_get_all_teams);

has 'hash' => ( is => 'ro', default => sub { {} } );
has 'teams' => ( is => 'ro', default => sub { [] } );

sub team {
	my ($self, $team) = @_;
	return $self->{hash}->{$team};
}

sub add_teams {
	my ($self, $results) = @_;
	
	my $teams = _get_all_teams ($results, 'home_team');
	for my $team (@$teams) {
		$self->{hash}->{$team} = Football::Team_Profit->new (team => $team);
		push (@{ $self->{teams} }, $team);
	}
}

sub place_stakes {
	my ($self, $home_team, $away_team) = @_;
	$self->{hash}->{$home_team}->staked ();
	$self->{hash}->{$away_team}->staked ();
}

sub home_win {
	my ($self, $team, $amount) = @_;
	$self->{hash}->{$team}->{home} += $amount;
	$self->{hash}->{$team}->{total} += $amount;
}

sub away_win {
	my ($self, $team, $amount) = @_;
	$self->{hash}->{$team}->{away} += $amount;
	$self->{hash}->{$team}->{total} += $amount;
}

sub percent {
	my ($self, $team) = @_;
	my $teamref = $self->{hash}->{$team};
	return sprintf "%.2f", $teamref->{total} / $teamref->{stake};
}

sub sort {
	my $self = shift;
	return sort {
		$self->percent ($b) <=> $self->percent ($a) 
		or $a cmp $b
	} @{ $self->{teams} };
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
