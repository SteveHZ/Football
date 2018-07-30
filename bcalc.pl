
# bcalc.pl 16-20/10/17, 28/10/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Modules';
use ComboGen;

my $formula = {};
my $filename = "C:/Mine/perl/Spreadsheets/bcalc.txt";

my $calc3 = do_calc (3);
my $calc4 = do_calc (4);
my $calc5 = do_calc (5);
my $calc6 = do_calc (6);
my $calc7 = do_calc (7);
my $calc8 = do_calc (8);
my $calc9 = do_calc (9);

my $dispatch = {
	"3 from 4"	=> $calc3->(4),
	"3 from 5"	=> $calc3->(5),
	"3 from 6"	=> $calc3->(6),
	"3 from 7"	=> $calc3->(7),
	"3 from 8"	=> $calc3->(8),
	"3 from 9"	=> $calc3->(9),
	"3 from 10" => $calc3->(10),
	
	"4 from 5"	=> $calc4->(5),
	"4 from 6"	=> $calc4->(6),
	"4 from 7"	=> $calc4->(7),
	"4 from 8"	=> $calc4->(8),
	"4 from 9"	=> $calc4->(9),
	"4 from 10"	=> $calc4->(10),

	"5 from 6"	=> $calc5->(6),
	"5 from 7"	=> $calc5->(7),
	"5 from 8"	=> $calc5->(8),
	"5 from 9"	=> $calc5->(9),
	"5 from 10"	=> $calc5->(10),

	"6 from 7"	=> $calc6->(7),
	"6 from 8"	=> $calc6->(8),
	"6 from 9"	=> $calc6->(9),
	"6 from 10"	=> $calc6->(10),

	"7 from 8"	=> $calc7->(8),
	"7 from 9"	=> $calc7->(9),
	"7 from 10"	=> $calc7->(10),

	"8 from 9"	=> $calc8->(9),
	"8 from 10"	=> $calc8->(10),
	"9 from 10"	=> $calc9->(10),
};
my $sorted = sort_dispatch_keys ($dispatch);

for my $func (@$sorted) {
	$formula->{$func} = $dispatch->{$func};
}

write_file ($filename, $formula, $sorted);

#	Sort dispatch keys numerically x from y
#	Alphabetic sort fails for x from 10

sub sort_dispatch_keys {
	my $dispatch = shift;

	return [	
		map	 { $_->[0]." from ".$_->[1] }
		sort {
			$a->[0] <=> $b->[0] or
			$a->[1] <=> $b->[1]
		}
		map	 { [ split ' from ', $_ ] } 	# transform '3 from 8 ' -> [3,8]
		keys %$dispatch
	];
}

sub write_file {
	my ($filename, $formula, $sorted) = @_;

	open my $fh,'>',$filename or die "Could not open $filename";

	for my $func (@$sorted) {
		print $fh "\n".$func;
		print $fh "\n".$formula->{$func};
	}
}

#	sub do_calc ($selections)
#	Function factory to calculate spreadsheet equations for permed trebles, 4folds etc.
#	Call as my $calc = do_calc (6) to return a sub which will calculate six-folds,
#	then call $calc->(3) or $calc->(4) to calculate '3 from 6' or '4 from 6' respectively

sub do_calc {
	my $sels = shift;
	my $cell;
	
	return sub {
		my $from = shift;

		my $str = "=(";
		my $start = 3; # first cell

		my @rows = ( $start..($start + ($from - 1)) );
		my $cells = [ map { "E".$_ } @rows ];
		my $gen = ComboGen->new ($sels, $from);
		my $combs = $gen->get_combs ($cells);

		print "\nCalculating $sels from $from";
		for my $group (@$combs) {
			$str .= "(". join ('*', @$group). ")+";
		}
		$str = substr $str,0,-1; # remove last '+'
		$str .= ")";
		
		return $str;
	}
}

=pod

=head1 NAME

bcalc.pl

=head1 SYNOPSIS

Create Open Office functions for bcalc spreadsheet

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

