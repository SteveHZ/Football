package Football::Scores_Iterator;

use Moo;
use namespace::clean;

has 'hash'		=> ( is => 'ro' );
has 'callback'	=> ( is => 'ro' );
has 'ht_max'	=> ( is => 'ro', default => 6 );
has 'ft_max'	=> ( is => 'ro', default => 10 );

sub run {
	my $self = shift;
	my ($half_time, $full_time);

	for my $hth (0...$self->{ht_max} ) {
		for my $hta (0...$self->{ht_max} ) {
			$half_time = sprintf ("%d-%d", $hth, $hta);

			for my $fth ($hth...$self->{ft_max} ) {
				for my $fta ($hta...$self->{ft_max} ) {
					$full_time = sprintf ("%d-%d", $fth, $fta);

					if ($self->{callback}) {
						$self->{callback}->( $self->{hash}, $half_time, $full_time );
					}
				}
			}
		}
	}
}

=pod

=head1 NAME

scores_iterator.pm

=head1 SYNOPSIS

Used by half_full.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
