package Football::Spreadsheets::Reports;

#	Spreadsheets::Reports.pm 01/03/16 - 07/13/16

use strict;
use warnings;

use parent 'Football::Spreadsheets::Base';

my $path = 'C:/Mine/perl/Football/reports/';
my $xlsx_files = {
	"League Places" => $path.'league_places.xlsx',
	"Goal Difference" => $path.'goal_difference.xlsx',
	"Recent Goal Difference" => $path.'recent_goal_difference.xlsx',
};

sub new {
	my ($class, $report) = @_;
	my $self = $class->SUPER::new ( $xlsx_files->{$report} );
    bless $self, $class;
    return $self;
}

sub do_league_places {
	my ($self, $hash) = @_;

	print "\n\nWriting league_places report...";
	my $worksheet = $self->{workbook}->add_worksheet ("League Places");
	$worksheet->set_column ('A:B', 15);
	$worksheet->set_column ('D:E', 15);

	$worksheet->merge_range ('A1:B1',"League Positions", $self->{bold_format});
	$worksheet->merge_range ('D1:F1',"Results", $self->{bold_format});

	$worksheet->write ('A2', "Home", $self->{bold_format});
	$worksheet->write ('B2', "Away", $self->{bold_format});

	$worksheet->write ('D2', "Home Wins", $self->{bold_format});
	$worksheet->write ('E2', "Away Wins", $self->{bold_format});
	$worksheet->write ('F2', "Draws", $self->{bold_format});

	my $row = 3;
	for my $home (1..20) {
		for my $away (1..20) {
			next if ($home == $away);
			$worksheet->write ($row, 0, $home, $self->{format});
			$worksheet->write ($row, 1, $away, $self->{format});
			$worksheet->write ($row, 3, $hash->{$home}->{$away}->{home_win}, $self->{format});
			$worksheet->write ($row, 4, $hash->{$home}->{$away}->{away_win}, $self->{format});
			$worksheet->write ($row, 5, $hash->{$home}->{$away}->{draw}, $self->{format});
			$row++;
		}
	}
	$worksheet->freeze_panes (3,0);
	$self->{workbook}->close ();
}

sub do_goal_difference {
	my ($self, $hash) = @_;

	print "\n\nWriting goal_difference report...";
	my $worksheet = $self->{workbook}->add_worksheet ("Goal Differences");
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);

	$worksheet->set_column ('A:A', 15);
	$worksheet->set_column ('C:E', 15);
	$worksheet->write ('A1', "Goal Difference", $self->{bold_format});
	$worksheet->merge_range ('C1:E1',"Results", $self->{bold_format});

	$worksheet->write ('A2', "Home", $self->{bold_format});
	$worksheet->write ('C2', "Home Wins", $self->{bold_format});
	$worksheet->write ('D2', "Away Wins", $self->{bold_format});
	$worksheet->write ('E2', "Draws", $self->{bold_format});

	my $row = 3;
	for my $goal_diff (-100..100) {
		$worksheet->write ($row, 0, $goal_diff, $self->{format});
		$worksheet->write ($row, 2, $hash->{$goal_diff}->{home_win}, $self->{format});
		$worksheet->write ($row, 3, $hash->{$goal_diff}->{away_win}, $self->{format});
		$worksheet->write ($row, 4, $hash->{$goal_diff}->{draw}, $self->{format});
		$row++;
	}
	$worksheet->freeze_panes (3,0);
	$self->{workbook}->close ();
}

sub do_recent_goal_diff {
	my ($self, $hash) = @_;

	print "\n\nWriting recent_goal_difference report...";
	my $worksheet = $self->{workbook}->add_worksheet ("Recent Goal Differences");
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);

	$worksheet->set_column ('A:A', 15);
	$worksheet->set_column ('C:E', 15);
	$worksheet->write ('A1', "Goal Difference", $self->{bold_format});
	$worksheet->merge_range ('C1:E1',"Results", $self->{bold_format});
	$worksheet->merge_range ('H1:J1',"Percentages", $self->{bold_format});

	$worksheet->write ('A2', "Home", $self->{bold_format});
	$worksheet->write ('C2', "Home Wins", $self->{bold_format});
	$worksheet->write ('D2', "Away Wins", $self->{bold_format});
	$worksheet->write ('E2', "Draws", $self->{bold_format});

	$worksheet->write ('H2', "Home", $self->{bold_format});
	$worksheet->write ('I2', "Away", $self->{bold_format});
	$worksheet->write ('J2', "Draw", $self->{bold_format});

	my $row = 3;
	my $data = 4;

	for my $goal_diff (-30..30) {
		$worksheet->write ($row, 0, $goal_diff, $self->{format});
		$worksheet->write ($row, 2, $hash->{$goal_diff}->{home_win}, $self->{format});
		$worksheet->write ($row, 3, $hash->{$goal_diff}->{away_win}, $self->{format});
		$worksheet->write ($row, 4, $hash->{$goal_diff}->{draw}, $self->{format});

		my $formulae = [
			'=IF(SUM(C'.$data.':E'.$data.'),(C'.$data.'/SUM(C'.$data.':E'.$data.'))*100,"0")',
			'=IF(SUM(C'.$data.':E'.$data.'),(D'.$data.'/SUM(C'.$data.':E'.$data.'))*100,"0")',
			'=IF(SUM(C'.$data.':E'.$data.'),(E'.$data.'/SUM(C'.$data.':E'.$data.'))*100,"0")',
		];
		my $per_cent_col = 7;
		for my $formula (@$formulae) {
			$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
		}
		$row++;
		$data++;
	}
	$worksheet->freeze_panes (3,0);
	$self->{workbook}->close ();
}

sub signed_goal_diff {
	my $worksheet = shift;
	my $col = $_[1];

	return undef unless $col == 0;
	if ($_[2] > 0) {
		my $signed = '+'.$_[2];
		return $worksheet->write_string ($_[0], $_[1], $signed, $_[3]); # row,col,number,format
	}
	return $worksheet->write_string (@_);
}

1;
