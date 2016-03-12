package Football::Spreadsheets::Predictions;

#	Predictions.pm 07/02/16 - 09/03/16

use strict;
use warnings;

use parent 'Football::Spreadsheets::Base';

my $path = 'C:/Mine/perl/Football/reports/';
my $xlsx_file = $path.'predictions.xlsx';

sub new {
	my $class = shift;
	my $self = $class->SUPER::new ($xlsx_file);
    bless $self, $class;
    return $self;
}

sub do_fixtures {
	my ($self, $fixtures) = @_;
	
	my $worksheet = $self->{workbook}->add_worksheet (" Homes and Aways ");
	do_fixtures_headers ($worksheet, $self->{bold_format});
	
	my $row = 2;
	my ($col, $result);
	for my $game (@$fixtures) {
		$col = 0;
		for $result (@ {$game->{homes}} ) {
			$worksheet->write ($row, $col++, $result, $self->{format});
		}
		$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});
		for $result (@ {$game->{aways}} ) {
			$worksheet->write ($row, $col ++, $result, $self->{format});
		}
		$col ++;
		$worksheet->write ($row, $col ++, $game->{home_points}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away_points}, $self->{format});
		$row ++;
	}
}

sub do_head2head {
	my ($self, $fixtures) = @_;
	
	my $worksheet = $self->{workbook}->add_worksheet (" Head To Head ");
	do_head2head_headers ($worksheet, $self->{bold_format});
	
	my $row = 2;
	my ($col, $result);
	for my $game (@$fixtures) {
		$col = 0;
		$worksheet->write ($row, $col ++, $game->{home}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away}, $self->{format});
		$col ++;
		for $result (@ {$game->{head2head}} ) {
			$worksheet->write ($row, $col ++, $result, $self->{format});
		}
		$col ++;
		$worksheet->write ($row, $col ++, $game->{home_h2h}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away_h2h}, $self->{format});
		$row ++;
	}
}

sub do_league_places {
	my ($self, $fixtures) = @_;

	my $worksheet = $self->{workbook}->add_worksheet (" League Placings ");
	do_league_place_headers ($worksheet, $self->{bold_format});
	
	my $row = 2;
	my ($col, $result);
	for my $game (@$fixtures) {
		$col = 0;
		$worksheet->write ($row, $col ++, $game->{home}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away}, $self->{format});
		$col ++;
		$worksheet->write ($row, $col ++, $game->{home_pos}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away_pos}, $self->{format});
		$col += 2;
		for my $result (@{ $game->{results}} ) {
			$worksheet->write ($row, $col ++, $result, $self->{format});
			$col ++;
		}
		my $formulae = build_formulae ($row + 1); # 0,0 = A1
		my $per_cent_col = 13;
		for my $formula (@$formulae) {
			$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
		}
		$row ++;
	}
}

sub do_goal_difference {
	my ($self, $fixtures) = @_;

	my $worksheet = $self->{workbook}->add_worksheet (" Goal Differences ");
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);
	do_goal_diff_headers ($worksheet, $self->{bold_format});
	
	my $row = 2;
	my $col;
	for my $game (@$fixtures) {
		$col = 0;
		$worksheet->write ($row, $col ++, $game->{home}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away}, $self->{format});
		$col += 2;
		$worksheet->write ($row, $col ++, $game->{goal_difference}, $self->{format});
		$col += 2;
		for my $result (@{ $game->{results}} ) {
			$worksheet->write ($row, $col ++, $result, $self->{format});
			$col ++;
		}
		my $formulae = build_formulae ($row + 1); # 0,0 = A1
		my $per_cent_col = 13;
		for my $formula (@$formulae) {
			$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
		}
		$row ++;
	}
}

sub do_recent_goal_difference {
	my ($self, $fixtures) = @_;

	my $worksheet = $self->{workbook}->add_worksheet (" Recent Goal Differences ");
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);
	do_goal_diff_headers ($worksheet, $self->{bold_format});
	
	my $row = 2;
	my $col;
	for my $game (@$fixtures) {
		$col = 0;
		$worksheet->write ($row, $col ++, $game->{home}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away}, $self->{format});
		$col += 2;
		$worksheet->write ($row, $col ++, $game->{recent_goal_difference}, $self->{format});
		$col += 2;
		for my $result (@{ $game->{results}} ) {
			$worksheet->write ($row, $col ++, $result, $self->{format});
			$col ++;
		}
		my $formulae = build_formulae ($row + 1); # 0,0 = A1
		my $per_cent_col = 13;
		for my $formula (@$formulae) {
			$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
		}
		$row ++;
	}
}

sub build_formulae {
	my $row = shift;
	return [
		'=IF(SUM(H'.$row.':L'.$row.'),(H'.$row.'/SUM(H'.$row.':L'.$row.'))*100,"0")',
		'=IF(SUM(H'.$row.':L'.$row.'),(J'.$row.'/SUM(H'.$row.':L'.$row.'))*100,"0")',
		'=IF(SUM(H'.$row.':L'.$row.'),(L'.$row.'/SUM(H'.$row.':L'.$row.'))*100,"0")',
	];
}

sub signed_goal_diff {
	my $worksheet = shift;
	my $col = $_[1];

	return undef unless $col == 4;
	if ($_[2] > 0) {
		my $signed = '+'.$_[2];
		return $worksheet->write_string ($_[0], $_[1], $signed, $_[3]); # row,col,number,format
	}
	return $worksheet->write_string (@_);
}

sub do_fixtures_headers {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ('A:F', 3);
	$worksheet->set_column ('G:H', 25);
	$worksheet->set_column ('I:N', 3);
	$worksheet->set_column ('O:Q', 5);

	$worksheet->merge_range ('A1:F1',"Home results",$format);
	$worksheet->write ('G1', "Home team", $format);
	$worksheet->write ('H1', "Away team", $format);
	$worksheet->merge_range ('I1:N1',"Away results", $format);
	$worksheet->merge_range ('P1:Q1',"Points", $format);
}

sub do_head2head_headers {
	my ($worksheet, $format) = @_;
	
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('D:I', 3);
	$worksheet->set_column ('K:L', 5);

	$worksheet->write ('A1', "Home team", $format);
	$worksheet->write ('B1', "Away team", $format);
	$worksheet->merge_range ('D1:I1',"Head to Head", $format);
	$worksheet->merge_range ('K1:L1',"Points", $format);
}

sub do_league_place_headers {
	my ($worksheet, $format) = @_;
	
	my @size3 = ('C:C', 'F:G', 'I:I', 'K:K');
	my @size8 = ('H:H', 'J:J', 'L:L');
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('D:E', 5);
	$worksheet->set_column ($_, 3) for (@size3);
	$worksheet->set_column ($_, 8) for (@size8);

	$worksheet->write ('A1', "Home team", $format);
	$worksheet->write ('B1', "Away team", $format);
	$worksheet->merge_range ('D1:E1',"Positions", $format);
	$worksheet->write ('H1', "Homes", $format);
	$worksheet->write ('J1', "Aways", $format);
	$worksheet->write ('L1', "Draws", $format);
	$worksheet->merge_range ('N1:P1',"Percentages", $format);
}

sub do_goal_diff_headers {
	my ($worksheet, $format) = @_;
	
	my @size3 = ('C:D', 'F:G', 'I:I', 'K:K');
	my @size8 = ('E:E', 'H:H', 'J:J', 'L:L');
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('E:E', 5);
	$worksheet->set_column ($_, 3) for (@size3);
	$worksheet->set_column ($_, 8) for (@size8);

	$worksheet->write ('A1', "Home team", $format);
	$worksheet->write ('B1', "Away team", $format);
	$worksheet->merge_range ('D1:F1',"Goal Difference", $format);
	$worksheet->write ('H1', "Homes", $format);
	$worksheet->write ('J1', "Aways", $format);
	$worksheet->write ('L1', "Draws", $format);
	$worksheet->merge_range ('N1:P1',"Percentages", $format);
}

1;
