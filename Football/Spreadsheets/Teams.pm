package Football::Spreadsheets::Teams;

#	Teams.pm 07/02/16

use strict;
use warnings;

use parent 'Football::Spreadsheets::Base';

my $path = 'C:/Mine/perl/Football/reports/';
my $xlsx_file = $path.'teams.xlsx';

sub new {
	my $class = shift;
	my $self = $class->SUPER::new ($xlsx_file);
    bless $self, $class;
    return $self;
}

sub do_teams {
	my ($self, $teams, $sorted) = @_;
	
	for my $team (@$sorted) {
		print "\nWriting data for $team...";
		my $worksheet = $self->{workbook}->add_worksheet ($team);
		do_teams_headers ($worksheet, $self->{bold_format});
		
		my $row = 1;
		my $next = $teams->{$team}->iterator ();
		while (my $list = $next->()) {
			$worksheet->write ($row, 0, $list->{date}, $self->{format});
			$worksheet->write ($row, 1, $list->{opponent}, $self->{format});
			$worksheet->write ($row, 2, $list->{home_away}, $self->{format});
			$worksheet->write ($row, 3, $list->{result}, $self->{format});
			$worksheet->write ($row, 4, $list->{score}, $self->{format});
			$row++;
		}
		$worksheet->freeze_panes (1,0);
		print "Done";
	}
}

sub do_teams_headers {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:B', 20);
	$worksheet->set_column ('B:C', 10);

	$worksheet->write ('A1', "DATE", $format);
	$worksheet->write ('B1', "OPPONENT", $format);
	$worksheet->write ('C1', "H/A", $format);
	$worksheet->write ('D1', "RESULT", $format);
	$worksheet->write ('E1', "SCORE", $format);
}

1;
