package Football::Spreadsheets::Goal_Expect_View;

#	Football::Spreadsheets::Goal_Expect_View.pm 30/08/17

use parent 'Football::Spreadsheets::Goal_Expect_View_Base';
use Football::Rules;

use Moo;
use namespace::clean;

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'goal_expect.xlsx';
}

sub get_rules {
	return Football::Rules->new ();
}

after 'do_goal_expect_header' => sub {
	my ($self, $worksheet) = @_;
	$self->set_columns ($worksheet, $self->after_get_column_sizes ());

	$worksheet->merge_range ('W1:X1', "GOAL DIFF", $self->{float_format} );
	$worksheet->write ('W2', "H/A", $self->{format} );
	$worksheet->write ('X2', "L6", $self->{format} );
	$worksheet->write ('Z1', "ODDS", $self->{format} );
	$worksheet->write ('AB1', "ODDS", $self->{format} );

	$worksheet->merge_range ('AD1:AG1', "OVER/UNDER", $self->{format} );
	$worksheet->write ('AD2', "H/A", $self->{format} );
	$worksheet->write ('AE2', "L6", $self->{format} );
	$worksheet->merge_range ('AF2:AG2', "ODDS", $self->{format} );
};

sub after_get_column_sizes {
	my $self = shift;

	return {
		"W:X" => { size => 7, fmt => $self->{float_format} },
		Y => { size => 2.5, fmt => $self->{blank_text_format2} },
		Z => { size => 10, fmt => $self->{format} },
		AA => { size => 2.5, fmt => $self->{blank_text_format2} },
		AB => { size => 10, fmt => $self->{float_format} },
		AC => { size => 20, fmt => $self->{blank_text_format2} },
		"AD:AG" => { size => 8, fmt => $self->{format} },
	};
}

1;