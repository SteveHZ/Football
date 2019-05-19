package Football::Spreadsheets::Combine_View2;

use Football::Spreadsheets::Combine_Expect;
use Football::Spreadsheets::Combine_Maxp;

use List::Util qw(any);
use Moo;
use namespace::clean;

extends qw(
    Football::Spreadsheets::Goal_Expect_View
    Football::Spreadsheets::Max_Profit
);

#   do_goal_expect and do_maxp
#   These two roles do most of the work for this module
with 'Football::Spreadsheets::Combine_Expect2';
with 'Football::Spreadsheets::Combine_Maxp2';

#sub BUILD {}
sub create_sheet {
    my $self = shift;
    my $path = 'C:/Mine/perl/Football/reports/';
    $self->{filename} = $path.'combined2.xlsx';
}

#   override Roles::Spreadsheet::write_row
#   to eliminate adding blank columns

=head
sub write_row {
	my ($self, $worksheet, $row, $row_data) = @_;

	my $col = 0;
	for my $cell_data (@$row_data) {
		while (my ($data, $fmt) = each %$cell_data) {
#			$col ++ while any { $col == $_ } @{ $self->blank_columns };
			$worksheet->write ( $row, $col ++, $data, $fmt );
		}
	}
}
=cut
=pod

=head1 NAME

Football::Spreadsheets::Combine_View.pm

=head1 SYNOPSIS

View for Game_Prediction triad
Most of the work for this module is done by
'Football::Spreadsheets::Combine_Expect'
and 'Football::Spreadsheets::Combine_Maxp'

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
