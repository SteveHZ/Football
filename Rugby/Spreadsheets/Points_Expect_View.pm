package Rugby::Spreadsheets::Points_Expect_View;

#	Rugby::Spreadsheets::Points_Expect_View.pm 26/07/17

use parent 'Football::Spreadsheets::Goal_Expect_View_Base';

use lib 'C:/Mine/perl/Football';
use Rugby::Rules;

use Moo;
use namespace::clean;

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/';
	$self->{filename} = $path.'points_expect.xlsx';
}

sub get_rules {
	return Rugby::Rules->new ();
}

after 'do_goal_expect_header' => sub {
	my ($self, $worksheet) = @_;

	$self->set_columns ($worksheet, $self->after_get_column_sizes ());

	$worksheet->merge_range ('W1:X1', "GOAL DIFF", $self->{float_format} );
	$worksheet->write ('W2', "H/A", $self->{format} );
	$worksheet->write ('X2', "L6", $self->{format} );

	$worksheet->write ('U1', "PD", $self->{format} );
	$worksheet->write ('Z1', "ODDS", $self->{format} );
	$worksheet->write ('AB1', "SKY", $self->{format} );
	$worksheet->write ('AC1', "B365", $self->{format} );
};

sub after_get_column_sizes {
	my $self = shift;
	
	return {
		"W:X" => { size => 7, fmt => $self->{float_format} },
		"Y AA" => { size => 2.5, fmt => $self->{blank_number_format2} },
		Z => { size => 10, fmt => $self->{format} },
		"AB:AC" => { size => 6, fmt => $self->{blank_number_format} },
	};
}

1;