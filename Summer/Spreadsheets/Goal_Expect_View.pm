package Summer::Spreadsheets::Goal_Expect_View;

#	Summer::Spreadsheets::Goal_Expect_View.pm 12/03/18

use parent 'Football::Spreadsheets::Goal_Expect_View';

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Summer/';
	$self->{filename} = $path.'goal_expect.xlsx';
}

1;