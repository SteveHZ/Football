package Football::Spreadsheets::Combine_Expect;

use MyRole;
requires qw(add_worksheet do_goal_expect_header do_formats write_row);

sub do_goal_expect ($self, $data, $files) {

    for my $file (@$files) {
        my $worksheet = $self->add_worksheet ($file->{name});
        $self->blank_columns ( [ qw( 2 4 6 9 11 14 16 19 22 25 27 28 29 31 ) ] );
        $self->do_goal_expect_header ($worksheet);

        my $row = 2;
        for my $game ( $data->{$file->{name}}->@* ) {
            my $row_data = $self->do_formats ($game);
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
	}
}

1;
