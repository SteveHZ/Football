package Football::Spreadsheets::Write_Series;

#	Football::Spreadsheets::Write_Series.pm 29/08/20

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;

	$self->create_sheet ();
	$self->{sheet_names} = $args->{sheet_names};
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'series.xlsx'
		unless defined $self->{filename};
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
		{ $data[0] => $self->{format} },         # League
		{ $data[1] => $self->{format} },         # Team Name
		{ $data[2] => $self->{float_format} }    # Percentage
	];
}

sub do_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 10) for (qw (A:A C:C));
	$worksheet->set_column ($_, 20) for (qw (B:B));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('B1', 'Team', $format);
	$worksheet->write ('C1', 'Percent', $format);
}

1;
