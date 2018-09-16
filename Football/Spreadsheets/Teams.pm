package Football::Spreadsheets::Teams;

#	Teams.pm 07/02/16
#	v1.1 06/05/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';


sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ($args->{filename});
}

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/divisions/';
	$self->{filename} = $path.$filename.'.xlsx';
}

sub do_teams {
	my ($self, $teams, $sorted) = @_;

	for my $team (@$sorted) {
		print "\nWriting data for $team...";
		my $worksheet = $self->add_worksheet ($team);
		$self->do_teams_headers ($worksheet);

		my $row = 1;
		if ( my $next = $teams->{$team}->iterator () ) {
#		my $next = $teams->{$team}->iterator () ) {
			while (my $list = $next->()) {
				$worksheet->write ($row, 0, $list->{date}, $self->{format});
				$worksheet->write ($row, 1, $list->{opponent}, $self->{format});
				$worksheet->write ($row, 2, $list->{home_away}, $self->{format});
				$worksheet->write ($row, 3, $list->{result}, $self->{format});
				$worksheet->write ($row, 4, $list->{score}, $self->{format});
				$row++;
			}
		}
		$worksheet->freeze_panes (1,0);
		print "Done";
	}
	$self->{workbook}->close ();
}

sub do_teams_headers {
	my ($self, $worksheet) = @_;

	$self->set_columns ($worksheet);

	$worksheet->write ('A1', 'DATE', $self->{bold_format});
	$worksheet->write ('B1', 'OPPONENT', $self->{bold_format});
	$worksheet->write ('C1', 'H/A', $self->{bold_format});
	$worksheet->write ('D1', 'RESULT', $self->{bold_format});
	$worksheet->write ('E1', 'SCORE', $self->{bold_format});
}

sub set_columns {
	my ($self, $worksheet) = @_;
	$worksheet->set_column ('A:B', 20);
	$worksheet->set_column ('B:C', 10);
}

1;
