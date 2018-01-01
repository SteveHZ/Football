package Football::Utils;

#	Football::Utils.pm 30/04/16

use strict;
use warnings;

use MyLib qw(unique);
use List::Util qw(any);

use Exporter 'import';
use vars qw ($VERSION @EXPORT_OK %EXPORT_TAGS);

$VERSION	 = 1.00;
@EXPORT_OK	 = qw (_show_signed _get_all_teams);  # symbols to export on request
%EXPORT_TAGS = ( All => [qw (&_show_signed &_get_all_teams)]);

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
	my @array = unique (
		db => $games,
		field => $field,
	);
	return \@array;
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
