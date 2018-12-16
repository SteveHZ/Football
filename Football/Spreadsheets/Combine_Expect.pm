package Football::Spreadsheets::Combine_Expect;

use Moo::Role;
use namespace::clean;
with 'Roles::Iterators'; # make_circular_iterator

requires qw(get_all_formats add_worksheet do_goal_expect_header write_row);

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

    my $iterator = make_circular_iterator ( $self->{blank_columns} );
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

1;
