package Football::Spreadsheets::Write_Returns;

#	Football::Spreadsheets::Write_Returns.pm 07-09/01/21

use Moo;
use List::MoreUtils qw(each_array each_arrayref);
use namespace::clean;

has 'filename' => (is => 'ro');
with 'Roles::Spreadsheet';

sub BUILD {
	my $self = shift;

	$self->{sheet_names} = [ "Wins", "Draws", "Defeats", "Overs", "Unders", ];
	$self->{season_stats} = [ "Wins", "Draws", "Defeats", "Overs", "Unders", ];
	$self->{recent_stats} = [ "Last Six Wins", "Last Six Draws", "Last Six Defeats", "Last Six Overs", "Last Six Unders", ];
}

sub write {
	my ($self, $hash) = @_;

	my $sheet_iterator = each_arrayref ($self->{sheet_names},
	 									$self->{season_stats},
										$self->{recent_stats});
	while (my ($sheet_name, $season_data, $recent_data) = $sheet_iterator->()) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		$self->blank_columns ( [ qw( 5 6 7 ) ] );
		$self->do_header ($worksheet, $self->{bold_format});

		my $row = 2;
		my $data_iterator = each_array ($hash->{$season_data}->@*,
										$hash->{$recent_data}->@*);
		while (my ($season, $recent) = $data_iterator->()) {
			my $row_data = $self->get_row_data ($season, $recent);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub get_row_data {
	my ($self, $season_data, $recent_data) = @_;
	my @sdata = split ",", $season_data;
	my @rdata = split ",", $recent_data;
	return [
		{ $sdata[0] => $self->{format} },		# League
		{ $sdata[1] => $self->{format} },		# Team Name
		{ $sdata[2] => $self->{format} },		# Stake
		{ $sdata[3] => $self->{float_format} },	# Return
		{ $sdata[4] => $self->{float_format} },	# Percentage

		{ $rdata[0] => $self->{format} },		# League
		{ $rdata[1] => $self->{format} },		# Team Name
		{ $rdata[2] => $self->{format} },		# Stake
		{ $rdata[3] => $self->{float_format} },	# Return
		{ $rdata[4] => $self->{float_format} },	# Percentage
	];
}

sub do_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 10) for (qw (A:A C:E I:I K:M));
	$worksheet->set_column ($_, 20) for (qw (B:B J:J));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('B1', 'Team', $format);
	$worksheet->write ('C1', 'Stake', $format);
	$worksheet->write ('D1', 'Return', $format);
	$worksheet->write ('E1', 'Percent', $format);

	$worksheet->write ('I1', 'League', $format);
	$worksheet->write ('J1', 'Team', $format);
	$worksheet->write ('K1', 'Stake', $format);
	$worksheet->write ('L1', 'Return', $format);
	$worksheet->write ('M1', 'Percent', $format);
}

1;

=pod

=head1 NAME

Write_Returns.pm

=head1 SYNOPSIS

Used by series.pl

=head1 DESCRIPTION

Writes out spreadsheets from data provided by returns.pl

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
