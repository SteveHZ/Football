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
		print "Done";
	}
}

#sub do_table {
#	my ($self, $table, $title) = @_;
#	$title //= "Table";
#	my $worksheet = $self->{workbook}->add_worksheet ($title);
#	do_table_headers ($worksheet, $self->{bold_format});
#
#	my $row = 3;
#	my $place = 1;
#	my $sorted = $table->sorted ();
#	for my $team (@$sorted) {
#		$worksheet->write ($row, 0, $place ++, $self->{format});
#		$worksheet->write ($row, 1, $team->{team}, $self->{format});
#		$worksheet->write ($row, 2, $team->{played}, $self->{format});
#		$worksheet->write ($row, 3, $team->{won}, $self->{format});
#		$worksheet->write ($row, 4, $team->{lost}, $self->{format});
#		$worksheet->write ($row, 5, $team->{drawn}, $self->{format});
#		$worksheet->write ($row, 6, $team->{for}, $self->{format});
#		$worksheet->write ($row, 7, $team->{against}, $self->{format});
#		$worksheet->write ($row, 8, $team->{for} - $team->{against}, $self->{format});
#		$worksheet->write ($row, 9, $team->{points}, $self->{format});
#		$row ++;
#	}
#}

#sub do_home_table {
#	my ($self, $table) = @_;
#	$self->do_table ($table, "Home Table");
#}

#sub do_away_table {
#	my ($self, $table) = @_;
#	$self->do_table ($table, "Away Table");
#}

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

#sub do_table_headers {
#	my ($worksheet, $format) = @_;
#
#	my @titles = (
#		{col=>'C2',title=>'Pl'}, {col=>'D2',title=>'W'}, {col=>'E2',title=>'L'},
#		{col=>'F2',title=>'D' }, {col=>'G2',title=>'F'}, {col=>'H2',title=>'A'},
#		{col=>'I2',title=>'GD'}, {col=>'J2',title=>'Pts'}
#	);
#	$worksheet->set_column ('A:A', 5);
#	$worksheet->set_column ('B:B', 20);
#	$worksheet->set_column ('C:J', 5);
#
#	for my $title (@titles) {
#		$worksheet->write ($title->{col}, $title->{title}, $format);
#	}
#}

1;
