package Rugby::Spreadsheets::Tables;

#	Rugby::Spreadsheets::Tables.pm 11/03/16 - 15/03/16
#	v1.1 06/05/17

use List::MoreUtils qw(each_arrayref);
use Football::Utils qw(_show_signed);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

extends 'Football::Spreadsheets::Tables';

sub create_sheet {
	my ($self, $filename) = @_;
	my $path = 'C:/Mine/perl/Football/reports/Rugby/tables/';
	$self->{filename} = $path.$filename.'.xlsx';
}

sub do_home_aways {
	my ($self, $list, $title, $home_away) = @_;
	my $worksheet = $self->add_worksheet ($title);
	$worksheet->add_write_handler( qr/^-?\d+(?:\.\d+)?$/, \&signed_goal_diff);

	do_form_header ($worksheet, $title, $self->{bold_format});
	my @sorted = sort { $list->{$b}->{points} <=> $list->{$a}->{points} 
						or $list->{$b}->{goal_difference} <=> $list->{$a}->{goal_difference}
						or $a cmp $b } keys %{$list};
	
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
		$worksheet->write ($row, ++$col, $self->get_average ($list->{$team}, $home_away), $self->{format} );
		$col ++;
		$worksheet->write ($row, ++$col, $list->{$team}->{points}, $self->{format});
		$row ++;
	}
}

sub get_average {
	my ($self, $team, $home_away) = @_;
	return 0 if scalar ( @{$team->{$home_away}} ) == 0;
	return sprintf ("%.02f", $team->{goal_difference} / scalar ( @{$team->{$home_away}} ));
}

sub do_table_header {
	my ($self, $worksheet, $format) = @_;

	my @titles = (
		{column=>'B2',title=>'Team'}, {column=>'C2',title=>'Pl'}, {column=>'D2',title=>'W'},
		{column=>'E2',title=>'L'},    {column=>'F2',title=>'D' }, {column=>'G2',title=>'F'},
		{column=>'H2',title=>'A'},    {column=>'I2',title=>'PD'}, {column=>'J2',title=>'Pts'}
	);
	$worksheet->set_column ('A:A', 5);
	$worksheet->set_column ('B:B', 25);
	$worksheet->set_column ('C:J', 5);

	for my $title (@titles) {
		$worksheet->write ($title->{column}, $title->{title}, $format);
	}
}

sub do_form_header {
	my ($worksheet, $title, $format) = @_;

	my @size5  = ('A:A','D:I', 'K:K','M:M');
	my @size8  = ('C:C', 'J:J', 'L:L', 'N:N');
	my @size25 = ('B:B');
	
	$worksheet->set_column ($_, 5)  for (@size5);
	$worksheet->set_column ($_, 8)  for (@size8);
	$worksheet->set_column ($_, 25) for (@size25);

	$worksheet->write ('B2', "Team", $format);
	$worksheet->merge_range ('D2:I2', $title, $format);
	$worksheet->write ('K2', "PD", $format);
	$worksheet->write ('L2', "Av", $format);
	$worksheet->write ('N2', "Points", $format);
}

sub signed_goal_diff {
	return _show_signed (@_, [ 10,11 ]);
}

1;
