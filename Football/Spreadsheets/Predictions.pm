package Football::Spreadsheets::Predictions;

#	Predictions.pm 07/02/16

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
	$worksheet->set_column ('A:F', 3);
	$worksheet->set_column ('G:H', 25);
	$worksheet->set_column ('I:N', 3);
	$worksheet->set_column ('O:Q', 5);

	$worksheet->merge_range ('A1:F1',"Home results",$self->{bold_format});
	$worksheet->write ('G1', "Home team", $self->{bold_format});
	$worksheet->write ('H1', "Away team", $self->{bold_format});
	$worksheet->merge_range ('I1:N1',"Away results", $self->{bold_format});
	$worksheet->merge_range ('P1:Q1',"Points", $self->{bold_format});
	
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
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('D:I', 3);
	$worksheet->set_column ('K:L', 5);

	$worksheet->write ('A1', "Home team", $self->{bold_format});
	$worksheet->write ('B1', "Away team", $self->{bold_format});
	$worksheet->merge_range ('D1:I1',"Head to Head", $self->{bold_format});
	$worksheet->merge_range ('K1:L1',"Points", $self->{bold_format});
	
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
	my @size3 = ('C:C', 'F:G', 'I:I', 'K:K');
	my @size8 = ('H:H', 'J:J', 'L:L');
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('D:E', 5);
	$worksheet->set_column ($_, 3) for (@size3);
	$worksheet->set_column ($_, 8) for (@size8);

	$worksheet->write ('A1', "Home team", $self->{bold_format});
	$worksheet->write ('B1', "Away team", $self->{bold_format});
	$worksheet->merge_range ('D1:E1',"Positions", $self->{bold_format});
	$worksheet->write ('H1', "Homes", $self->{bold_format});
	$worksheet->write ('J1', "Aways", $self->{bold_format});
	$worksheet->write ('L1', "Draws", $self->{bold_format});
	
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
		$row ++;
	}
}

sub do_goal_difference {
	my ($self, $fixtures) = @_;

	my $worksheet = $self->{workbook}->add_worksheet (" Goal Differences ");
	my @size3 = ('C:D', 'F:G', 'I:I', 'K:K');
	my @size8 = ('E:E', 'H:H', 'J:J', 'L:L');
	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('E:E', 5);
	$worksheet->set_column ($_, 3) for (@size3);
	$worksheet->set_column ($_, 8) for (@size8);

	$worksheet->write ('A1', "Home team", $self->{bold_format});
	$worksheet->write ('B1', "Away team", $self->{bold_format});
	$worksheet->merge_range ('D1:F1',"Goal Difference", $self->{bold_format});
	$worksheet->write ('H1', "Homes", $self->{bold_format});
	$worksheet->write ('J1', "Aways", $self->{bold_format});
	$worksheet->write ('L1', "Draws", $self->{bold_format});
	
	my $row = 2;
	my ($col, $goal_diff, $result);
	for my $game (@$fixtures) {
		$col = 0;
		$goal_diff = ($game->{goal_difference} > 0) ? ' +'.$game->{goal_difference} : $game->{goal_difference};
		$worksheet->write ($row, $col ++, $game->{home}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{away}, $self->{format});
		$col += 2;
		$worksheet->write ($row, $col ++, $goal_diff, $self->{format});
		$col += 2;
		for my $result (@{ $game->{results}} ) {
			$worksheet->write ($row, $col ++, $result, $self->{format});
			$col ++;
		}
		$row ++;
	}
}
1;
