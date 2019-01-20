package Football::Spreadsheets::HalfTime_FullTime;

#	HalfTime_FullTime.pm 07-21/05/16

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro');
with 'Roles::Spreadsheet';

use Football::Scores_Iterator;

my $path = 'C:/Mine/perl/Football/reports/';
my $filename = 'halftime_fulltime.xlsx';

sub BUILD {
	my $self = shift;
	$self->{filename} = $path.$filename;
}

sub do_half_times {
	my ($self, $hash, $sorted, $half_times) = @_;

	for my $half_time (@$sorted) {
		print "\nWriting worksheet for $half_time...";
		my $worksheet = $self->{workbook}->add_worksheet ($half_time);
		do_header ($worksheet, $self->{bold_format});

		my @list = sort {
			$hash->{$half_time}->{$b} <=> $hash->{$half_time}->{$a}
		} keys %{ $hash->{$half_time} };

		my $row = 1;
		for my $full_time (@list) {
			my $per_cent = sprintf ("%.2f %%", ($hash->{$half_time}->{$full_time} / $half_times->{$half_time}) * 100);
			$worksheet->write ($row, 0, $full_time, $self->{format});
			$worksheet->write ($row, 2, $hash->{$half_time}->{$full_time}, $self->{format});
			$worksheet->write ($row, 4, $per_cent, $self->{format});
			$row ++;
		}
	}
	$self->{workbook}->close ();
}

sub do_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ($_, 10) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 15) for (qw (E:E));
	$worksheet->set_column ($_, 5) for (qw (B:B D:D));

	$worksheet->write ('A1', 'FULL TIME', $format);
	$worksheet->write ('C1', 'GAMES', $format);
	$worksheet->write ('E1', 'PERCENTAGE', $format);
}

1;
