package Football::Spreadsheets::Combine_View;

use Football::Spreadsheets::Combine_Expect;
use Football::Spreadsheets::Combine_Maxp;

use Moo;
use namespace::clean;

use parent qw (
    Football::Spreadsheets::Goal_Expect_View
    Football::Spreadsheets::Max_Profit
);

#   do_goal_expect and do_maxp
#   These two roles do most of the work for this module
with 'Football::Spreadsheets::Combine_Expect';
with 'Football::Spreadsheets::Combine_Maxp';

sub create_sheet {
    my $self = shift;
    my $path = 'C:/Mine/perl/Football/reports/';
    $self->{filename} = $path.'combined.xlsx';
}

#   override Roles::Spreadsheet::write_row
#   to eliminate adding blank columns

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

1;
