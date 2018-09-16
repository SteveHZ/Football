
# bcalc2.pl 24-28/10/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Modules';
use ComboGen;

my $formula = {};
my $filename = 'C:/Mine/perl/Spreadsheets/bcalc2.txt';

my $ptrixie = do_perms (3);
my $ppatent = do_perms (3);
my $pyankee = do_perms (4);

my $dispatch = {
	'permed trixie from 4' => $ptrixie->(4,1), # flag for trixie
	'permed patent from 4' => $ppatent->(4),
	'permed patent from 5' => $ppatent->(5),
	'permed patent from 6' => $ppatent->(6),

	'permed yankee from 5' => $pyankee->(5),
	'permed yankee from 6' => $pyankee->(6),
};

for my $func (%$dispatch) {
	$formula->{$func} = $dispatch->{$func};
}

write_file ($filename, $formula, $dispatch);

sub write_file {
	my ($filename, $formula, $dispatch) = @_;

	open my $fh,'>',$filename or die "Could not open $filename";

	for my $func (keys %$dispatch) {
		print $fh "\n".$func;
		print $fh "\n$_" for @{ $formula->{$func} };
	}
}

#	sub do_perms ($selections)
#	Function factory to calculate spreadsheet equations for permed patents and permed yankees.
#	Call as my $calc = do_perms (4) to return a sub which will calculate permed yankees,
#	then call $calc->(5) or $calc->(6) to calculate yankees for 5 or 6 selections respectively

sub do_perms {
	my $sels = shift;

	return sub {
		my ($from, $trixie) = @_;
		$trixie //= 0;
		my @formulas = ();

		print "\n\nCalculating $sels from $from";
		my $gen = ComboGen->new ($sels, $from);
		my $coderef = sub {
			my $obj = shift;
			my $genref = $obj->get_array (deep_copy => 0);

			my $str = '=';
			if (! $trixie) {
				$str .= build_singles ($genref) if $sels == 3; # permed patent
			}
			my $multiples = build_multiples->($sels, $genref);
			for my $multis (2..$sels) {
				$str .= $multiples->($multis);
			}
			$str =~ s/\+$//; # remove trailing '+'
			push @formulas, $str;
		};
		$gen->onIteration ($coderef);
		$gen->run ();

		print "\n$_" for @formulas;
		return \@formulas;
	}
}

#	build_singles ($genref)
#	create equation for singles in a permed patent

sub build_singles {
	my $genref = shift;
	my $start = 3;

	my @temp = map { 'I'.( $start + $_ ) } @$genref;
	return '('. join ('+', @temp). ')+';
}

#	sub build_multiples ($from, $genref)
#	Function factory to calculate spreadsheet equations for multiples within permed patents or yankees.
#	Call as my $calc = build_multiples (4) to return a sub which will calculate permed yankees,
#	then call $calc->(2) or $calc->(3) to calculate doubles or trebles respectively

sub build_multiples {
	my ($from, $genref) = @_;

	return sub {
		my $sels = shift;
		my $start = 3; # first ce''ll
		my $str = '';

		my $gen = ComboGen->new ($sels, $from);
		my $coderef = sub {
			my $obj = shift;
			my $objref = $obj->get_array (deep_copy => 0);				# get current state of this generator

			my @temp = map { 'I'.( $start + @$genref [$_] ) } @$objref;	# index into other generator passed into build_multiples
			$str .= '('. join ('*', @temp). ')+';
		};

		$gen->onIteration ($coderef);
		$gen->run ();
		return $str;
	}
}

=pod

=head1 NAME

bcalc2.pl

=head1 SYNOPSIS

Create Open Office functions for bcalc spreadsheet (permed patents and yankees)

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
