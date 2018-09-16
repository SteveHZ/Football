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

	$worksheet->merge_range ('X1:Y1', 'GOAL DIFF', $self->{float_format} );
	$worksheet->write ('X2', 'H/A', $self->{format} );
	$worksheet->write ('Y2', 'L6', $self->{format} );
	$worksheet->write ('AA1', 'ODDS', $self->{format} );
	$worksheet->write ('AC1', 'ODDS', $self->{format} );

	$worksheet->merge_range ('AE1:AJ1', 'OVER/UNDER', $self->{format} );
	$worksheet->write ('AE2', 'PTS', $self->{format} );
	$worksheet->write ('AG2', 'H/A', $self->{format} );
	$worksheet->write ('AH2', 'L6', $self->{format} );
	$worksheet->merge_range ('AI2:AJ2', 'ODDS', $self->{format} );
};

sub after_get_column_sizes {
	my $self = shift;

	return {
		"X:Y" => { size => 7, fmt => $self->{float_format} },
		Z => { size => 2.5, fmt => $self->{blank_text_format2} },
		AA => { size => 10, fmt => $self->{format} },
		"AB AD AF" => { size => 2.5, fmt => $self->{blank_text_format2} },
		AC => { size => 7, fmt => $self->{float_format} },
		AE => { size => 8, fmt => $self->{format} },
		"AG:AJ" => { size => 8, fmt => $self->{format} },
	};
}

1;
