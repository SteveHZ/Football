package Football::Roles::Signed;

use List::Util qw(any);
use Moo::Role;

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

=pod

=head1 NAME

Football::Roles::Signed.pm

=head1 SYNOPSIS

Used by spreadsheet classes

=head1 DESCRIPTION

Include '+' sign in spreadsheet values

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
