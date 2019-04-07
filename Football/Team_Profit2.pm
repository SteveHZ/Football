package Football::Team_Profit2;

use Mu;
use namespace::clean;

ro 'team';
ro 'balance', default => 20;
ro 'stake', default => 0;
ro 'home', default => 0;
ro 'away', default => 0;
ro 'total', default => 0;

ro 'total_stake', default => 0;
ro 'home_stake', default => 0;
ro 'away_stake', default => 0;
ro 'home_win', default => 0;
ro 'away_win', default => 0;

sub home_staked {
	my $self = shift;

    $self->{balance} /= 2;
	$self->{stake} = $self->{balance};
    $self->{total_stake} += $self->{balance};
	$self->{home_stake} += $self->{balance};
}

sub away_staked {
	my $self = shift;

    $self->{balance} /= 2;
	$self->{stake} = $self->{balance};
    $self->{total_stake} += $self->{balance};
	$self->{away_stake} += $self->{balance};
}

sub home_add {
	my ($self, $amount) = @_;
    my $return_amount = $self->{stake} * $amount;
	$self->{home} += $return_amount;
	$self->{balance} += $return_amount;
}

sub away_add {
	my ($self, $amount) = @_;
    my $return_amount = $self->{stake} * $amount;
	$self->{away} += $return_amount;
	$self->{balance} += $return_amount;
}

sub percent {
	my $self = shift;
	return sprintf "%.4f",
		_percent_gain ( $self->{balance}, $self->{total} );
}

sub home_percent {
	my $self = shift;
	return sprintf "%.4f",
		_percent_gain ( $self->{home_stake}, $self->{home} );
}

sub away_percent {
	my $self = shift;
	return sprintf "%.4f",
		_percent_gain ( $self->{away_stake}, $self->{away} )
}

sub _percent_gain {
	my ($initial_amount, $closing_amount) = @_;
	return (($closing_amount - $initial_amount) / $initial_amount);
}

sub home_win_rate {
	my $self = shift;
	return _win_rate ($self->{home_win}, $self->{home_stake});
}

sub away_win_rate {
	my $self = shift;
	return _win_rate ($self->{away_win}, $self->{away_stake});
}

sub total_win_rate {
	my $self = shift;
	return _win_rate ($self->{home_win} + $self->{away_win}, $self->{stake});
}

sub _win_rate {
	my ($wins, $stake) = @_;
	return $wins / $stake;
}

=pod

=head1 NAME

Team_Profit2.pm

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
