package Football::Spreadsheets::Tables;

#	Football::Spreadsheets::Tables.pm 11/03/16 - 15/03/16
#	v1.1 06/05/17

use List::MoreUtils qw(each_arrayref);
use Football::Utils qw(_show_signed);

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
	my $path = 'C:/Mine/perl/Football/reports/tables/';
	$self->{filename} = $path.$filename.'.xlsx';
}

sub do_table {
	my ($self, $table, $title) = @_;
	$title //= "Table";

	my $worksheet = $self->add_worksheet ($title);
	$worksheet->add_write_handler( qr/^-?\d+$/, \&table_signed_goal_diff);
	$self->do_table_header ($worksheet, $self->{bold_format});

	my $row = 3;
	my $league_place = 1;
	for my $team (@$table) {
		$worksheet->write ($row, 0, $league_place ++, $self->{format});
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
	my $worksheet = $self->add_worksheet ($title);
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);

	do_form_header ($worksheet, $title, $self->{bold_format});
	my @sorted = sort {
		$list->{$b}->{points} <=> $list->{$a}->{points}
		or $list->{$b}->{goal_difference} <=> $list->{$a}->{goal_difference}
		or $a cmp $b
	} keys %$list;

	my $row = 3;
	my $place = 1;
	for my $team (@sorted) {
		my $col = 3;
		my $full_str = "full_".$home_away;

		$worksheet->write ($row, 0, $place ++, $self->{format});
		$worksheet->write ($row, 1, $list->{$team}->{name}, $self->{format});

		my $iterator = each_arrayref ( $list->{$team}->{$home_away}, $list->{$team}->{$full_str} );
		while ( my ($result, $full_result) = $iterator->() ) {
			$worksheet->write ($row, $col, $result, $self->{format});
			$worksheet->write_comment ($row, $col++,
				"$full_result->{date} $full_result->{opponent} \n($full_result->{home_away}) $full_result->{score}");
		}
		$col = 10;
		$worksheet->write ($row, $col, $list->{$team}->{goal_difference}, $self->{format});
		$worksheet->write ($row, ++$col, $list->{$team}->{points}, $self->{format});
		$row ++;
	}
	$self->do_draws ($worksheet, $list, "Home Draws");
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

sub do_draws {
	my ($self, $worksheet, $list, $title) = @_;
	my $row = 3;
	my $col = 13;

	my @sorted = sort {
		$list->{$b}->{draws} <=> $list->{$a}->{draws}
		or $a cmp $b
	} keys %$list;
	for my $team (@sorted) {
		$worksheet->write ($row, $col, $list->{$team}->{name}, $self->{format});
		$worksheet->write ($row ++, $col + 1, $list->{$team}->{draws}, $self->{format});
	}
}

sub do_table_header {
	my ($self, $worksheet, $format) = @_;

	my @titles = (
		{column=>'B2',title=>'Team'}, {column=>'C2',title=>'Pl'}, {column=>'D2',title=>'W'},
		{column=>'E2',title=>'L'},    {column=>'F2',title=>'D' }, {column=>'G2',title=>'F'},
		{column=>'H2',title=>'A'},    {column=>'I2',title=>'GD'}, {column=>'J2',title=>'Pts'}
	);
	$worksheet->set_column ('A:A', 5);
	$worksheet->set_column ('B:B', 20);
	$worksheet->set_column ('C:J', 5);

	for my $title (@titles) {
		$worksheet->write ($title->{column}, $title->{title}, $format);
	}
}

sub do_form_header {
	my ($worksheet, $title, $format) = @_;

	$worksheet->set_column ($_, 5)  for (qw (A:A D:I K:K));
	$worksheet->set_column ($_, 8)  for (qw (C:C J:J));
	$worksheet->set_column ($_, 20) for (qw (B:B N:N));

	$worksheet->write ('B2', "Team", $format);
	$worksheet->merge_range ('D2:I2', $title, $format);
	$worksheet->write ('K2', "GD", $format);
	$worksheet->write ('L2', "Points", $format);
	$worksheet->merge_range ('N2:O2', "Draws" , $format);
}

sub table_signed_goal_diff {
	return _show_signed (@_, [ 8 ]);
}

sub signed_goal_diff {
	return _show_signed (@_, [ 10 ]);
}

1;
