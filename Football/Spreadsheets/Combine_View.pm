package Football::Spreadsheets::Combine_View;
use Data::Dumper;
use parent qw (
    Football::Spreadsheets::Goal_Expect_View
    Football::Spreadsheets::Max_Profit
);

sub create_sheet {
    my $self = shift;
    my $path = 'C:/Mine/perl/Football/reports/';
    $self->{filename} = $path.'combined.xlsx';
}

#   override Roles::Spreadsheet::write_row
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
            my $row_data = $self->get_expect_rows ($game);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
	}
}

sub get_expect_rows {
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
    my $cols_format = $self->get_maxp_format ();

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->do_header ($worksheet, $self->{bold_format});
        my $row = 2;

        for my $team (@{ $data->{ $file->{name} } } ) {
            my $row_data = $self->get_maxp_rows ($team, $cols_format);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
    }
}

sub get_maxp_format {
    my $self = shift;
    my @formats = (
        $self->{format}, $self->{blank_text_format2},
        $self->{currency_format}, $self->{percent_format},
    );
    my @formats_idx = qw(0 1 0 1 2 1 2 1 2 1 2 1 3);

    return [
        map { $formats [$_] } @formats_idx
    ];
}

sub get_maxp_rows {
    my ($self, $team, $cols_format) = @_;
    my $iter = make_iter ($cols_format);
    return [
        map { { $_ => $iter->() } } @$team
    ];
}

sub make_iter {
    my $formats = shift;
    my $index = 0;

    return sub {
        return @$formats [ $index++];
    }
}

=head
# second version for expect
sub do_goal_expect {
    my ($self, $data, $files) = @_;
    my $cols_format = $self->get_expect_format ();

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->do_goal_expect_header ($worksheet);

        my $row = 2;
        for my $game (@{ $data->{ $file->{name} } } ) {
            my $row_data = $self->get_expect_rows ($game, $cols_format);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
	}
}

sub get_expect_format {
    my $self = shift;
    my @formats = (
        $self->{format}, $self->{blank_text_format2},
        $self->{float_format}, $self->{blank_number_format2},
    );
    my @formats_idx = (
        0,0,1,0,1,0,1,          # A-G
        2,2,1,2,1,2,2,1,2,1,    # H-Q
        2,2,1,2,2,3,2,2,1,      # R-Z
        0,1,2,1,0,1,0,0,0,0,    # AA-AJ
    );
    return [
        map { $formats [$_] } @formats_idx
    ];
}

sub get_expect_rows {
    my ($self, $team, $cols_format) = @_;
    my $iter = make_iter ($cols_format);
    return [
        map { { $_ => $iter->() } } @$team
    ];
}


# original version for maxp
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
    my $formats = [
        $self->{format}, $self->{blank_text_format2},
        $self->{currency_format}, $self->{percent_format},
    ];
    my $formats_idx = [ qw(0 1 0 1 2 1 2 1 2 1 2 1 3) ];
    my $iter = make_iter ($formats, $formats_idx);

    return [
        map { { $_ => $iter->() } } @$team
    ];
}

sub make_iter {
    my ($formats, $formats_idx) = @_;
    my $index = 0;

    return sub {
        return @$formats [ @$formats_idx [$index++] ];
    }
}
=cut

1;
