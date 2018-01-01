package Football::Season;

# 	Football::Season.pm 15/02/16, 02-04/05/16
#	Mouse version 05-06/05/16

use Date::Simple;
use Moo;
use namespace::clean;

has 'start' => ( is => 'rw' );
has 'end' => ( is => 'rw' );
has 'max_games' => ( is => 'ro' );
has 'week' => ( is => 'rw', default => 1 );
has 'count' => ( is => 'rw', default => 1 );

sub BUILD {
	my ($self, $args) = @_;
	( $self->{start}, $self->{end} ) = init_dates ( $args->{start_date} );
	$self->{max_games} = $args->{league_size} / 2;
}

sub check {
	my ($self, $date_in) = @_;

	my $date = get_date ($date_in);
	my $check = $self->{start} + 2;

	if ( date_greater_than ($date, $check) or # if date > check
	 	 $self->{count}++ >= $self->{max_games}) {
		if ($date > $self->{end}) {
			while ($date >= $self->{end} ) { # an international weekend ?
				$self->{start} = $self->{end} + 1;
				$self->{end} = $self->{start} + 6;
			}
		} else { # midweek matches
			$self->{start} = $date;
		}
		$self->{week} ++;
		$self->{count} = 1;
	}
	return $self->{week};
}

sub init_dates {
	my $start_date = shift;

	my $start = get_date ($start_date);
	my $next = $start + 6;
	return ($start, $next);
}

sub get_date {
	my $date = shift;

	my ($day, $month, $year) = split (/\//, $date);
	if ($year > 1900) {
	#	year expressed as four digits (1990, 2016)
		return Date::Simple->new ("$year-$month-$day");
	} else {
	#	year expressed as two digits (90,16)
		my $century = ($year > 80) ? 19 : 20;
		return Date::Simple->new ($century."$year-$month-$day");
	}
}

sub date_greater_than {
	my ($first, $second) = @_;
	return ($first > $second) ? 1 : 0;
}

sub get_dates {
	my $self = shift;
	return ( $self->{start}, $self->{end} );
}

=pod

=head1 NAME

season.pm

=head1 SYNOPSIS

Used by create_reports.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;