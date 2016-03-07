package Football::Season;

# Football::Season.pm 15/02/16

use strict;
use warnings;
use DateTime;

sub new {
	my ($class, $start_date) = @_;

	my ($start_week, $end_week) = init_dates ($start_date);
	my $self = {
		week => 1,
		count => 1,
		start => $start_week,
		end => $end_week,
	};
    bless $self, $class;
    return $self;
}

sub check {
	my ($self, $date_in) = @_;
	
	my $date = get_datetime ($date_in);
	if ($date >= $self->{end} || $self->{count}++ > 10) {
		while ($date >= $self->{end} ) {
			$self->{start} = $self->{end}->add (days => 1);
			$self->{end} = $self->{start}->clone->add (days => 6);
		}
		$self->{week} ++;
		$self->{count} = 1;
	}
	return $self->{week};
}

sub init_dates {
	my $start_date = shift;

	my $start = get_datetime ($start_date);
	my $next = $start->clone->add (days => 6);
	return ($start, $next);
}

sub get_datetime {
	my $date = shift;

	my ($day, $month, $year) = split (/\//, $date);
	my $century = ($year > 80) ? 19 : 20;
	return DateTime->new (
		day		=> $day,
		month	=> $month,
		year 	=> $century.$year,
	);
}

1;
