package Football::Spreadsheets::Tables;

#	Football::Spreadsheets::Tables.pm 11/03/16

use strict;
use warnings;

use parent 'Football::Spreadsheets::Base';

my $path = 'C:/Mine/perl/Football/reports/';
my $xlsx_file = $path.'tables.xlsx';

sub new {
	my $class = shift;
	my $self = $class->SUPER::new ($xlsx_file);
    bless $self, $class;
    return $self;
}

sub do_table {
	my ($self, $table, $title) = @_;
	$title //= "Table";
	my $worksheet = $self->{workbook}->add_worksheet ($title);
	do_table_headers ($worksheet, $self->{bold_format});

	my $row = 3;
	my $place = 1;
	my $sorted = $table->sorted ();
	for my $team (@$sorted) {
		$worksheet->write ($row, 0, $place ++, $self->{format});
		$worksheet->write ($row, 1, $team->{team}, $self->{format});
		$worksheet->write ($row, 2, $team->{played}, $self->{format});
		$worksheet->write ($row, 3, $team->{won}, $self->{format});
		$worksheet->write ($row, 4, $team->{lost}, $self->{format});
		$worksheet->write ($row, 5, $team->{drawn}, $self->{format});
		$worksheet->write ($row, 6, $team->{for}, $self->{format});
		$worksheet->write ($row, 7, $team->{against}, $self->{format});
		$worksheet->write ($row, 8, $team->{for} - $team->{against}, $self->{format});
		$worksheet->write ($row, 9, $team->{points}, $self->{format});
		$row ++;
	}
}

sub do_home_table {
	my ($self, $table) = @_;
	$self->do_table ($table, "Home Table");
}

sub do_away_table {
	my ($self, $table) = @_;
	$self->do_table ($table, "Away Table");
}

sub do_home_aways {
	my ($self, $list, $title, $home_away) = @_;
	my $worksheet = $self->{workbook}->add_worksheet ($title);
	do_form_headers ($worksheet, $title, $self->{bold_format});

	my @sorted = sort {$b->{points} <=> $a->{points} or $a->{team} cmp $b->{team} } @$list;
	
	my $row = 3;
	for my $team (@sorted) {
		$worksheet->write ($row, 0, $team->{team}, $self->{format});
		my $col = 2;
		for my $game (@{ $team->{$home_away} }) {
			$worksheet->write ($row, $col ++, $game, $self->{format});
		}
		$worksheet->write ($row, ++$col, $team->{points}, $self->{format});
		$row ++;
	}
}

sub do_homes {
	my ($self, $list, $title) = @_;
	$self->do_home_aways ($list, $title, "homes");
}

sub do_aways {
	my ($self, $list, $title) = @_;
	$self->do_home_aways ($list, $title, "aways");
}

sub do_last_six {
	my ($self, $list, $title) = @_;
	$self->do_home_aways ($list, $title, "last_six");
}

sub do_extended {
	my ($self, $fixtures) = @_;
	
	my $row = 0;
	my $worksheet = $self->{workbook}->add_worksheet ("Extended");
	do_extended_headers ($worksheet, $self->{format});
	
	for my $game (@$fixtures) {
		$worksheet->merge_range ($row, 0, $row, 3, uc ($game->{home_team}). " ". $game->{home_points}, $self->{bold_format});
		$worksheet->merge_range ($row, 5, $row, 8, uc ($game->{away_team}). " ". $game->{away_points}, $self->{bold_format});

		my $start_row = ++$row;
		my @temp = reverse ($game->{full_homes});
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

sub do_table_headers {
	my ($worksheet, $format) = @_;

	my @titles = (
		{col=>'C2',title=>'Pl'}, {col=>'D2',title=>'W'}, {col=>'E2',title=>'L'},
		{col=>'F2',title=>'D' }, {col=>'G2',title=>'F'}, {col=>'H2',title=>'A'},
		{col=>'I2',title=>'GD'}, {col=>'J2',title=>'Pts'}
	);
	$worksheet->set_column ('A:A', 5);
	$worksheet->set_column ('B:B', 20);
	$worksheet->set_column ('C:J', 5);

	for my $title (@titles) {
		$worksheet->write ($title->{col}, $title->{title}, $format);
	}
}

sub do_form_headers {
	my ($worksheet, $title, $format) = @_;

	my @size5 = ('C:H', 'J:J');
	my @size8 = ('B:B', 'I:I');
	$worksheet->set_column ('A:A', 20);
	$worksheet->set_column ($_, 5) for (@size5);
	$worksheet->set_column ($_, 8) for (@size8);

	$worksheet->write ('A2', "Team", $format);
	$worksheet->merge_range ('C2:H2', $title, $format);
	$worksheet->write ('J2', "Points", $format);
}

sub do_extended_headers {
	my ($worksheet, $format) = @_;
	
	my @size20 = ('B:B', 'G:G');
	my @size10 = ('A:A', 'F:F');
	my @size5 = ('C:D', 'H:I');
	$worksheet->set_column ($_,20) for @size20;
	$worksheet->set_column ($_,10) for @size10;
	$worksheet->set_column ($_,5) for @size5;
}

1;
