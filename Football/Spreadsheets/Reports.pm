package Football::Spreadsheets::Reports;

#	Spreadsheets::Reports.pm 01/03/16 - 09/13/16

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
	do_league_place_headers ($worksheet, $self->{bold_format});
	
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
	do_goal_diff_headers ($worksheet, $self->{bold_format});

	my $row = 3;
	for my $goal_diff (-100..100) {
		$worksheet->write ($row, 0, $goal_diff, $self->{format});
		$worksheet->write ($row, 2, $hash->{$goal_diff}->{home_win}, $self->{format});
		$worksheet->write ($row, 3, $hash->{$goal_diff}->{away_win}, $self->{format});
		$worksheet->write ($row, 4, $hash->{$goal_diff}->{draw}, $self->{format});

		my $formulae = build_formulae ($row + 1); # 0,0 = A1
		my $per_cent_col = 7;
		for my $formula (@$formulae) {
			$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
		}
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
	do_goal_diff_headers ($worksheet, $self->{bold_format});
	
	my $row = 3;
	for my $goal_diff (-30..30) {
		$worksheet->write ($row, 0, $goal_diff, $self->{format});
		$worksheet->write ($row, 2, $hash->{$goal_diff}->{home_win}, $self->{format});
		$worksheet->write ($row, 3, $hash->{$goal_diff}->{away_win}, $self->{format});
		$worksheet->write ($row, 4, $hash->{$goal_diff}->{draw}, $self->{format});

		my $formulae = build_formulae ($row + 1); # 0,0 = A1
		my $per_cent_col = 7;
		for my $formula (@$formulae) {
			$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
		}
		$row++;
	}
	$worksheet->freeze_panes (3,0);
	$self->{workbook}->close ();
}

sub build_formulae {
	my $row = shift;
	return [
		'=IF(SUM(C'.$row.':E'.$row.'),(C'.$row.'/SUM(C'.$row.':E'.$row.'))*100,"0")',
		'=IF(SUM(C'.$row.':E'.$row.'),(D'.$row.'/SUM(C'.$row.':E'.$row.'))*100,"0")',
		'=IF(SUM(C'.$row.':E'.$row.'),(E'.$row.'/SUM(C'.$row.':E'.$row.'))*100,"0")',
	];
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

sub do_league_place_headers {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:B', 15);
	$worksheet->set_column ('D:E', 15);

	$worksheet->merge_range ('A1:B1',"League Positions", $format);
	$worksheet->merge_range ('D1:F1',"Results", $format);

	$worksheet->write ('A2', "Home", $format);
	$worksheet->write ('B2', "Away", $format);

	$worksheet->write ('D2', "Home Wins", $format);
	$worksheet->write ('E2', "Away Wins", $format);
	$worksheet->write ('F2', "Draws", $format);
}

sub do_goal_diff_headers {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ('A:A', 15);
	$worksheet->set_column ('C:E', 15);
	$worksheet->write ('A1', "Goal Difference", $format);
	$worksheet->merge_range ('C1:E1',"Results", $format);
	$worksheet->merge_range ('H1:J1',"Percentages", $format);

	$worksheet->write ('A2', "Home", $format);
	$worksheet->write ('C2', "Home Wins", $format);
	$worksheet->write ('D2', "Away Wins", $format);
	$worksheet->write ('E2', "Draws", $format);

	$worksheet->write ('H2', "Home", $format);
	$worksheet->write ('I2', "Away", $format);
	$worksheet->write ('J2', "Draw", $format);
}

1;
