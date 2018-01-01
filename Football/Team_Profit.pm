package Football::Team_Profit;

use Moo;
use namespace::clean;

has 'team'  => ( is => 'ro' );
has 'stake' => ( is => 'ro', default => 0 );
has 'home'  => ( is => 'ro', default => 0 );
has 'away'  => ( is => 'ro', default => 0 );
has 'total' => ( is => 'ro', default => 0 );

sub staked {
	my $self = shift;
	$self->{stake} ++;
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
	return sprintf "%.2f", $self->{total} / $self->{stake};
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
