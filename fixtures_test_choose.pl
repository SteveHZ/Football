use strict;
use warnings;
use v5.10;
use Term::Choose qw(choose);
use Data::Dumper;
use Time::Piece qw(localtime);
use Time::Seconds qw(ONE_DAY);

do_football ();

sub do_football {
	my $args = get_args ();
	print Dumper $args; <STDIN>;
	my $week = get_week (0,$args); # 0:$self
	print Dumper $week;
}


sub get_args {
	my $days = choose (
        [ qw ( 1 2 3 4 5 6 7 ) ],
        { prompt => 'How many days ?' }
    );
    my $today = choose (
    	[ qw ( n y ) ],
        { prompt => 'Include today ?' },
#        { prompt => 'Include today ?', index => 1 },
    );
    return {
		days => $days,
		include_today => $today,
	};
}

sub get_week {
	my ($self, $args) = @_;
	my $days = $args->{days};

#	0 includes today, 1 will start from tomorrow
#	Default value to include today is 1 , hence exclusive OR $today to start from day 0

#	We need 0 to indicate to include today, and 1 to start from tomorrow
#	However, the returned value to include today is 1 (list index of [n y]), and 0 to not include today
#	Therefore, exclusive OR $args->{include_today} to start from day 0,
#	then decrement $days to count eg 0..3 rather than 1..4
#	my $start_date = $args->{include_today} ^ 1;

	my $start_date = ($args->{include_today} eq 'y')  ? 0 : 1;

	$days-- if $start_date == 0;
#if ($start_date == 0) {$days--;}
	my @week = ();
	my $today = localtime;

	for my $day_count ($start_date..$days) {
		my $day = $today + ($day_count * ONE_DAY);
		push @week, {
			day	 => substr ($day->wdayname, 0, 2),
			date => $day->ymd,
		};
	}
	return \@week;
}
