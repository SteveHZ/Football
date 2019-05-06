package Football::Roles::Odds_Cols;

use List::MoreUtils qw(firstidx);
use Moo::Role;

sub get_odds_cols {
	my ($data, $search_for) = @_;
	$search_for //= "B365H";

	my $odds_col = firstidx { $_ eq $search_for }
		( ref ($data) eq "ARRAY" )
			? @{ $data->[0] }		#	xlsx
			: split (',', $data);	#	csv

	return ($odds_col...$odds_col + 2);
}

sub get_euro_odds_cols {
	my $data = shift;
	return get_odds_cols ($data, "AvgH");
}

sub get_over_under_cols {
	my $data = shift;
	my @header = split (',', $data);

#	Need to assign these two variables first, then write to hash in scalar context (DON'T change !!)
	my $over  = firstidx { $_ eq 'BbAv>2.5' } @header;
	my $under = firstidx { $_ eq 'BbAv<2.5' } @header;
	return {
		over  => $over,
		under => $under,
	};
}

=pod

=head1 NAME

Football::Roles::Odds_Cols.pm

=head1 SYNOPSIS

used by Football::Favourites::Data_Model

=head1 DESCRIPTION

Routines for finding odds columns in FootballData Spreadsheets

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
