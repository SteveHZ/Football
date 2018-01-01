package Football::Poisson;

# 16/10/16

use Math::CDF qw(ppois qpois);
use v5.22;

use Moo;
use namespace::clean;

my $max_score = 5;

sub BUILD {
	my $self = shift;
	$self->{score} = [];
	$self->refresh ();
}

sub refresh {
	my $self = shift;
	
	$self->{running_total} = 0;
	for my $home (0..$max_score) {
		for my $away (0..$max_score) {
			$self->{score}[$home][$away] = 0;
		}
	}
}

sub calc_all {
	my ($self, $home_expect, $away_expect) = @_;
	
	for my $home (0..$max_score) {
		for my $away (0..$max_score) {
#			$self->{score}[$home][$away] =  $self->do_calc2 ($home, $home_expect) *
#											$self->do_calc2 ($away, $away_expect) * 100;
			$self->{score}[$home][$away] =  do_calc ($home, $home_expect) *
											do_calc ($away, $away_expect) * 100;
		}
	}
}

sub calc {
	my ($self, $home_score, $away_score, $home_expect, $away_expect) = @_;
	
#	return sprintf "%.3f",  $self->do_calc2 ($home_score, $home_expect) *
#							$self->do_calc2 ($away_score, $away_expect) * 100;
	return sprintf "%.3f",  do_calc ($home_score, $home_expect) *
							do_calc ($away_score, $away_expect) * 100;
}

sub do_calc {
#	cumulative poisson function
	my ($score, $value) = @_;
	return ppois ($score, $value);
}

sub do_calc2 {
#	attempt to write non-cumulative poisson function
	my ($self, $score, $value) = @_;
	my $temp = $self->{running_total};
	$self->{running_total} = ppois ($score, $value);

	say "temp = $temp";
	say "running_total = $self->{running_total}";
#	<STDIN>;
	
	return $self->{running_total} - $temp;
}

sub print_all {
	my $self = shift;
	
	for my $home (0..$max_score) {
		for my $away (0..$max_score) {
			say "$home-$away : $self->{score}[$home][$away]";
		}
	}
}

sub power {
	my ($self, $num, $exp) = @_;
	return $num ** $exp;
}

1;
