package Football::Spreadsheets::Write_Series;

#	Football::Spreadsheets::Write_Series.pm 24/10/20, 12/12/22

use Moo;
use namespace::clean;

has 'filename' => (is => 'ro');
with 'Roles::Spreadsheet';

sub BUILD {
	my $self = shift;

	$self->{sheet_names} = [
		"All Results", "All OU Results",
		"Wins", "Home Wins", "Away Wins",
		"Draws", "Home Draws", "Away Draws",
		"Defeats", "Home Defeats", "Away Defeats",
		"Overs", "Home Overs", "Away Overs",
		"Unders", "Home Unders", "Away Unders",
		"Over Unders", "Under Overs",
		"L6 Over Unders", "L6 Under Overs",
#		"All Results", "All OU Results"
   ];
}

sub write {
	my ($self, $hash) = @_;

	for my $sheet_name ($self->{sheet_names}->@*) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		if ($sheet_name eq "All Results" || $sheet_name eq "All OU Results") {
			$self->do_header2 ($worksheet, $self->{bold_format});
		} else {
			$self->do_header ($worksheet, $self->{bold_format});
		}

		my $row = 2;
		my $row_data;
		for my $team_data ($hash->{$sheet_name}->@*) {
			if ($sheet_name eq "All Results" || $sheet_name eq "All OU Results") {
				$row_data = $self->get_row_data2 ($team_data);
			} else {
				$row_data = $self->get_row_data ($team_data);
			}
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

# For all sheets except "All Results" and "All OU Results"
sub get_row_data {
	my ($self, $team_data) = @_;
	my @data = split ",", $team_data;
	return [
		{ $data[0] => $self->{format} },       		# League
		{ $data[1] => $self->{format} },         	# Team Name
		{ $data[2] => $self->{float_format} },    	# Stake
		{ $data[3] => $self->{float_format} },    	# Return
		{ $data[4] => $self->{float_format} },    	# Percentage
	];
}

# Header for all sheets except "All Results" and "All OU Results"
sub do_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 10) for (qw (A:A C:E));
	$worksheet->set_column ($_, 20) for (qw (B:B));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('B1', 'Team', $format);
	$worksheet->write ('C1', 'Stake', $format);
	$worksheet->write ('D1', 'Return', $format);
	$worksheet->write ('E1', 'Percent', $format);
}

# Only for "All Results" and "All OU Results" sheets
sub get_row_data2 {
	my ($self, $team_data) = @_;
	my @data = split ",", $team_data;
	return [
		{ $data[0] => $self->{format} },       		# League
		{ $data[1] => $self->{format} },         	# Team Name
		{ $data[2] => $self->{format} },    		# Result
		{ $data[3] => $self->{float_format} },    	# Stake
		{ $data[4] => $self->{float_format} },    	# Return
		{ $data[5] => $self->{float_format} },    	# Percentage
	];
}

# Header for "All Results" and "All OU Results" sheets
sub do_header2 {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 10) for (qw (A:A D:F));
	$worksheet->set_column ($_, 20) for (qw (B:C));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('B1', 'Team', $format);
	$worksheet->write ('C1', 'Result', $format);
	$worksheet->write ('D1', 'Stake', $format);
	$worksheet->write ('E1', 'Return', $format);
	$worksheet->write ('F1', 'Percent', $format);
}

=cut

=pod

=head1 NAME

Write_Series.pm

=head1 SYNOPSIS

Used by series.pl

=head1 DESCRIPTION

Writes out spreadsheets from data provided by series.pl

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
