package Football::Utils;

#	Football::Utils.pm 30/04/16

use strict;
use warnings;

use MyLib qw(unique);
use List::Util qw(any);
use List::MoreUtils qw(firstidx);

use Exporter 'import';
use vars qw (@EXPORT_OK %EXPORT_TAGS);

@EXPORT_OK	 = qw (_show_signed _get_all_teams get_odds_cols get_euro_odds_cols get_over_under_cols );
%EXPORT_TAGS = (all => \@EXPORT_OK);

sub _show_signed {
	my $worksheet = shift;
	my $col = $_[1];

	return undef unless any {$col == $_} @{$_[4]};
	if ($_[2] > 0) {
		my $signed = '+'.$_[2];
		return $worksheet->write_string ($_[0], $_[1], $signed, $_[3]); # row,col,data,format
	}
	return $worksheet->write_string (@_);
}

sub _get_all_teams {
	my ($games, $field) = @_;
	$field //= 'home_team';

	return unique (
		db => $games,
		field => $field,
	);
}

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

Utils.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

Utilty routines for predict.pl

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
