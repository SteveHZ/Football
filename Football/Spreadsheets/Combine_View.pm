package Football::Spreadsheets::Combine_View;

use parent qw (
    Football::Spreadsheets::Goal_Expect_View
    Football::Spreadsheets::Max_Profit
);

sub create_sheet {
    my $self = shift;
    my $path = 'C:/Mine/perl/Football/reports/';
    $self->{filename} = $path.'combined.xlsx';
}

#   override write_row from Roles::Spreadsheet
#   to eliminate adding blank columns
sub write_row {
	my ($self, $worksheet, $row, $row_data) = @_;

	my $col = 0;
	for my $cell_data (@$row_data) {
		while (my ($data, $fmt) = each %$cell_data) {
#			$col ++ while any { $col == $_ } @{ $self->blank_columns };
			$worksheet->write ( $row, $col ++, $data, $fmt );
		}
	}
}

sub do_goal_expect {
    my ($self, $data, $files) = @_;

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->do_goal_expect_header ($worksheet);

        my $row = 2;
        for my $game (@{ $data->{ $file->{name} } } ) {
            my $row_data = $self->get_goal_expect_rows ($game);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
	}
}

sub get_goal_expect_rows {
	my ($self, $game) = @_;
    return [
        map {
            ($_ eq '')      ? { $_ => $self->{blank_text_format2} } :
            ($_ =~ /\d*/)   ? { $_ => $self->{float_format} } :
                              { $_ => $self->{format} }
        } @$game
    ];
}

sub do_maxp {
	my ($self, $data, $files) = @_;

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->do_header ($worksheet, $self->{bold_format});

        my $row = 2;
        for my $team (@{ $data->{ $file->{name} } } ) {
            my $row_data = $self->get_maxp_rows ($team);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
    }
}

sub get_maxp_rows {
    my ($self, $team) = @_;

    return [
        map {
            ($_ ne '')  ? { $_ => $self->{format} } :
                          { $_ => $self->{blank_text_format2} }

        } @$team
    ];
}

1;
