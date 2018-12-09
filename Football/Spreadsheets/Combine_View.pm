package Football::Spreadsheets::Combine_View;

use strict;
use warnings;

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
    my $formats = $self->get_all_formats ();

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->do_goal_expect_header ($worksheet);

        my $row = 2;
        for my $game (@{ $data->{ $file->{name} } } ) {
            my $row_data = $self->do_formats ($game, $formats);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
	}
}

sub do_formats {
	my ($self, $data, $formats, $game) = @_;
    my @row_data = ();
	my ($col_idx, $fmt_idx) = (0,0);

    my $iterator = make_iterator ( $self->{blank_columns} );
    my $next_blank = $iterator->();

    for my $rowdata (@$data) {
        if ($col_idx == $next_blank) {
            push @row_data, { $rowdata => $self->{blank_text_format2} };
            $next_blank = $iterator->();
        } else {
            push @row_data,
                ($rowdata ne '') ? { $rowdata => @$formats [$fmt_idx] }
                                 : { $rowdata => $self->{format} };
            $fmt_idx ++;
        }
        $col_idx ++;
    }

#   get formats for Home Team, Away Team, Home/Away and Last Six
	$row_data [3]  = { @$data [3]  => $self->get_format ( @$data [10] * -1 ) };
	$row_data [5]  = { @$data [5]  => $self->get_format ( @$data [10] ) };
	$row_data [10] = { @$data [10] => $self->get_format ( @$data [10] ) };
	$row_data [15] = { @$data [15] => $self->get_format ( @$data [15] ) };
	return \@row_data;
}

sub do_maxp {
	my ($self, $data, $files) = @_;
    my $iterator = make_iterator ($self->get_maxp_format ());

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->do_header ($worksheet, $self->{bold_format});

        my $row = 2;
        for my $team (@{ $data->{ $file->{name} } } ) {
            my $row_data = get_row_data ($team, $iterator);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
    }
}

sub make_iterator {
    my $array = shift;
    my $index = 0;

    return sub {
        $index = 0 if $index > $#$array;
        return @$array [ $index++ ];
    }
}

sub get_maxp_format {
    my $self = shift;
    my @formats = (
        $self->{format}, $self->{blank_text_format2},
        $self->{currency_format}, $self->{percent_format},
    );
    my @formats_idx = qw(0 1 0 1 2 1 2 1 2 1 2 1 3 1 3);

    return [
        map { $formats [$_] } @formats_idx
    ];
}

sub get_row_data {
    my ($row, $iterator) = @_;

    return [
        map { { $_ => $iterator->() } } @$row
    ];
}

1;
