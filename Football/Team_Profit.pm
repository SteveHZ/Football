package Football::Team_Profit;

use Mu;
use namespace::clean;

ro 'team';
ro 'stake', default => 0;
ro 'home', default => 0;
ro 'away', default => 0;
ro 'total', default => 0;
ro 'home_stake', default => 0;
ro 'away_stake', default => 0;
ro 'home_win', default => 0;
ro 'away_win', default => 0;

sub home_staked {
	my $self = shift;
	$self->{stake} ++;
	$self->{home_stake} ++;
}

sub away_staked {
	my $self = shift;
	$self->{stake} ++;
	$self->{away_stake} ++;
}

sub home_add {
	my ($self, $amount) = @_;
	$self->{home} += $amount;
	$self->{total} += $amount;
}

sub away_add {
	my ($self, $amount) = @_;
	$self->{away} += $amount;
	$self->{total} += $amount;
}

sub percent {
	my $self = shift;
	return sprintf "%.4f",
		percent_gain ( $self->{stake}, $self->{total} );
}

sub home_percent {
	my $self = shift;
	return sprintf "%.4f",
		percent_gain ( $self->{home_stake}, $self->{home} );
}

sub away_percent {
	my $self = shift;
	return sprintf "%.4f",
		percent_gain ( $self->{away_stake}, $self->{away} )
}

sub percent_gain {
	my ($initial_amount, $closing_amount) = @_;
	return (($closing_amount - $initial_amount) / $initial_amount);
}

=pod

=head1 NAME

Team_Profit.pm

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
