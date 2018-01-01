package Football::Spreadsheets::Extended;

#	Football::Spreadsheets::Extended.pm 19/04/16
#	v1.1 06/05/17

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my $self = shift;	
	$self->create_sheet ();
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'extended.xlsx';
}

sub do_extended {
	my ($self, $fixtures) = @_;

	for my $league (@$fixtures) {
		my $row = 1;
		my $league_name = $league->{league};
		my $worksheet = $self->add_worksheet ($league_name);
		do_extended_header ($worksheet, $self->{format});
	
		for my $game (@{ $league->{games} } ) {
			$worksheet->merge_range ($row, 0, $row, 3, uc ($game->{home_team}). " ". $game->{home_points}, $self->{bold_format});
			$worksheet->merge_range ($row, 5, $row, 8, uc ($game->{away_team}). " ". $game->{away_points}, $self->{bold_format});

			my $start_row = ++$row;
			for my $previous ($game->{full_homes}) {
				for my $match ( reverse @$previous) {
					$worksheet->write ($row, 0, $match->{date}, $self->{format});
					$worksheet->write ($row, 1, $match->{opponent}, $self->{format});
					$worksheet->write ($row, 2, $match->{result}, $self->{format});
					$worksheet->write ($row ++, 3, $match->{score}, $self->{format});
				}
			}
			$row = $start_row;
			for my $previous ($game->{full_aways}) {
				for my $match (reverse @$previous) {
					$worksheet->write ($row, 5, $match->{date}, $self->{format});
					$worksheet->write ($row, 6, $match->{opponent}, $self->{format});
					$worksheet->write ($row, 7, $match->{result}, $self->{format});
					$worksheet->write ($row ++, 8, $match->{score}, $self->{format});
				}
			}
			$row ++;
		}
	}
}

sub do_extended_header {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ($_,5)  for ('C:D', 'H:I');
	$worksheet->set_column ($_,10) for ('A:A', 'F:F');
	$worksheet->set_column ($_,20) for ('B:B', 'G:G');
}

1;
