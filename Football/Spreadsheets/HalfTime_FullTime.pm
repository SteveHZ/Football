package Football::Spreadsheets::HalfTime_FullTime;

#	HalfTime_FullTime.pm 07-21/05/16
#	Added write_to_org_file method 13/08/23

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro');
with 'Roles::Spreadsheet';

use Football::Scores_Iterator;

my $path = 'C:/Mine/perl/Football/reports';
my $filename = 'halftime_fulltime.xlsx';

my $org_path = 'C:/Users/steve/Dropbox/org';
my $org_filename = 'Half Times.org';


sub BUILD {
	my $self = shift;
	$self->{filename} = "$path/$filename"; # required by Roles::Spreadsheet
}

sub do_half_times {
	my ($self, $hash, $sorted, $half_times) = @_;

	open my $fh, '>', "$org_path/$org_filename" or die "Can't open org file $org_path/$org_filename !!!"; 

	print $fh "* Half-Time Scores";
	for my $half_time (@$sorted) {
		print "\nWriting worksheet and org file for $half_time...";
		my $worksheet = $self->{workbook}->add_worksheet ($half_time);
		do_header ($worksheet, $self->{bold_format});

		# Sort the list of full time scores associated with $half_time
		my $full_time_list = [
			sort {
				$hash->{$half_time}->{$b} <=> $hash->{$half_time}->{$a}
			} keys $hash->{$half_time}->%*
		];

		my $row = 1;
		print $fh "\n** $half_time";
		
		for my $full_time (@$full_time_list) {
			$self->write_to_xlsx ($worksheet, $hash, $half_time, $half_times, $full_time, $row);
			$row ++;
			write_to_org_file ($fh, $hash, $half_time, $half_times, $full_time);
		}
	}
	$self->{workbook}->close ();
	close $fh;
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

sub write_to_xlsx {
	my ($self, $worksheet, $hash, $half_time, $half_times, $full_time, $row) = @_;

	my $per_cent = sprintf ("%.2f %%", ($hash->{$half_time}->{$full_time} / $half_times->{$half_time}) * 100);
	$worksheet->write ($row, 0, $full_time, $self->{format});
	$worksheet->write ($row, 2, $hash->{$half_time}->{$full_time}, $self->{format});
	$worksheet->write ($row, 4, $per_cent, $self->{format});
}

sub write_to_org_file {
	my ($fh, $hash, $half_time, $half_times, $full_time) = @_;

	my $full_time_value = sprintf ("%4d", $hash->{$half_time}->{$full_time});
	my $per_cent = sprintf ("%5.2f %%", ($hash->{$half_time}->{$full_time} / $half_times->{$half_time}) * 100);

	print $fh "\n*** $full_time $full_time_value  $per_cent";
} 

=begin comment
sub write_to_org_file {
	my ($self, $fh, $hash, $half_time, $half_times, $full_time_list) = @_;

	print $fh "\n** $half_time";
	for my $full_time (@$full_time_list) {
		my $full_time_value = sprintf ("%4d", $hash->{$half_time}->{$full_time});
		my $per_cent = sprintf ("%5.2f %%", ($hash->{$half_time}->{$full_time} / $half_times->{$half_time}) * 100);

		print $fh "\n*** $full_time $full_time_value  $per_cent";
	}
} 

# Write to XLSX and org files withhin this loop to avoid having seperate functions,
# passing 6 arguments to each and then having to iterate the loop again !!!
			
			# Write to XLSX spreadsheet
#			my $per_cent = sprintf ("%.2f %%", ($hash->{$half_time}->{$full_time} / $half_times->{$half_time}) * 100);
#			$worksheet->write ($row, 0, $full_time, $self->{format});
#			$worksheet->write ($row, 2, $hash->{$half_time}->{$full_time}, $self->{format});
#			$worksheet->write ($row, 4, $per_cent, $self->{format});
#			$row ++;

			# write to org file
#			my $full_time_value = sprintf ("%4d", $hash->{$half_time}->{$full_time});
#			$per_cent = sprintf ("%5.2f %%", ($hash->{$half_time}->{$full_time} / $half_times->{$half_time}) * 100);
#			print $fh "\n*** $full_time $full_time_value  $per_cent";

=end comment
=cut

1;
