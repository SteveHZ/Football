package Football::Spreadsheets::GoalExpectView_v3;

#	Football::Spreadsheets::Goal_Expect_View.pm 30/08/17

use parent 'Football::Spreadsheets::Goal_Expect_View_Base_v3';
use Football::Rules;

use Moo;
use namespace::clean;

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/v3/';
	$self->{filename} = $path.'goal_expect.xlsx';
}

sub get_rules {
	return Football::Rules->new ();
}

after 'do_goal_expect_header' => sub {
	my ($self, $worksheet) = @_;

	$worksheet->set_column ($_, 2.5, $self->{blank_text_format2} ) for ('Y:Y','AE:AE');
	$worksheet->set_column ($_, 7, $self->{float_format} ) for ('W:X');
	$worksheet->set_column ($_, 5, $self->{format} ) for ('Z:Z','AB:AB','AF:AF');
	$worksheet->set_column ($_, 5, $self->{blank_number_format3} ) for ('AA:AA');
	
	$worksheet->set_column ($_, 10, $self->{format} ) for ('AD:AD');
	$worksheet->set_column ($_, 10, $self->{blank_number_format} ) for ('AF:AF');
	$worksheet->set_column ($_, 10, $self->{blank_text_format2} ) for ('AG:AG');
	$worksheet->set_column ($_, undef, undef, 1) for ('G:I','L:N','Z:AC'); # hide columns

	$worksheet->merge_range ('W1:X1', "GOAL DIFF", $self->{float_format} );
	$worksheet->merge_range ('Z1:AB1', "OVER/UNDER", $self->{format} );
	$worksheet->write ('W2', "H/A", $self->{format} );
	$worksheet->write ('X2', "L6", $self->{format} );
	$worksheet->write ('Z2', "H/A", $self->{format} );
	$worksheet->write ('AA2', "L6", $self->{format} );
	$worksheet->write ('AB2', "ODDS", $self->{format} );
	$worksheet->write ('AD1', "ODDS", $self->{format} );
	$worksheet->write ('AF1', "ODDS", $self->{format} );
};

1;