package Football::Spreadsheets::Write_Series;

#	Football::Spreadsheets::Write_Series.pm 24/10/20

use Moo;
use namespace::clean;

has 'filename' => (is => 'ro');
with 'Roles::Spreadsheet';

sub BUILD {
	my $self = shift;

	$self->{sheet_names} = [
		"Wins", "Home Wins", "Away Wins",
		"Draws", "Home Draws", "Away Draws",
		"Defeats", "Home Defeats", "Away Defeats",
		"Overs", "Home Overs", "Away Overs",
		"Unders", "Home Unders", "Away Unders",
		"Over Unders", "Under Overs",
   ];
}

sub write {
	my ($self, $hash) = @_;

	for my $sheet_name ($self->{sheet_names}->@*) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		$self->do_header ($worksheet, $self->{bold_format});

		my $row = 2;
		for my $team_data ($hash->{$sheet_name}->@*) {
			my $row_data = $self->get_row_data ($team_data);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

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

sub do_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 10) for (qw (A:A C:C));
	$worksheet->set_column ($_, 20) for (qw (B:B));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('B1', 'Team', $format);
	$worksheet->write ('C1', 'Stake', $format);
	$worksheet->write ('D1', 'Return', $format);
	$worksheet->write ('E1', 'Percent', $format);
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
