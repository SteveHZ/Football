
#	do_calc_bench.pl 12/11/17

use strict;
use warnings;

use ComboGen;
use Benchmark qw(:all);

my $callback = do_calc_callback (3);
my $func1 = do_calc_functional_1 (3);
my $func2 = do_calc_functional_2 (3);
my $func3 = do_calc_direct (3);

my $t = timethese (100000, {
#my $t = timethese (-15, {
#my $t = timethese (-10, {
	'callback' => sub {
		$callback->(5);
	},
	'functional v1' => sub {
		$func1->(5);
	},
	'functional v2' => sub {
		$func2->(5);
	},
	'direct' => sub {
		$func3->(5);
	},
});
cmpthese ($t);

sub do_calc_callback {
	my $sels = shift;
	my $cell;

	return sub {
		my $from = shift;
		my $start = 3; # first cell
		my $str = '=(';

		my $gen = ComboGen->new ($sels, $from);
		my $coderef = sub {
			my $obj = shift;
			my $objref = $obj->get_array (deep_copy => 0);

			my @temp = map { 'E'.( $start + $_ ) } @$objref;
			$str .= '('. join ('*', @temp). ')+';
		};
		$gen->onIteration ($coderef);
		$gen->run ();

		$str = substr $str,0,-1; # remove last '+'
		$str .= ')';
		return $str;
	}
}

sub do_calc_functional_1 {
	my $sels = shift;
	my $cell;

	return sub {
		my $from = shift;
		my $start = 3; # first cell
		my $str = '=(';

		my $gen = ComboGen->new ($sels, $from);
		my $rows = [ $start..(3 + ($from - 1)) ];
		my $combs = $gen->get_combs ($rows);

		for my $group (@$combs) {
			my @temp = map { 'E'.$_ } @$group;
			$str .= '('. join ('*', @temp). ')+';
		}
		$str = substr $str,0,-1; # remove last '+'
		$str .= ')';

		return $str;
	}
}

sub do_calc_functional_2 {
	my $sels = shift;
	my $cell;

	return sub {
		my $from = shift;

		my $str = '=(';
		my $start = 3; # first cell

		my @rows = ( $start..($start + ($from - 1)) );
		my $cells = [ map { 'E'.$_ } @rows ];
		my $gen = ComboGen->new ($sels, $from);
		my $combs = $gen->get_combs ($cells);

		for my $group (@$combs) {
			$str .= '('. join ('*', @$group). ')+';
		}
		$str = substr $str,0,-1; # remove last '+'
		$str .= ')';

		return $str;
	}
}

sub do_calc_direct {
	my $sels = shift;
	my $cell;

	return sub {
		my $from = shift;

		my $str = '=(';
		my $start = 3; # first cell

		my @rows = ( $start..($start + ($from - 1)) );
		my $cells = [ map { 'E'.$_ } @rows ];
		my $gen = ComboGen->new ($sels, $from);
		my $combs = $gen->map_to ($cells);

		for my $group (@$combs) {
			$str .= '('. join ('*', @$group). ')+';
		}
		$str = substr $str,0,-1; # remove last '+'
		$str .= ')';

		return $str;
	}
}
