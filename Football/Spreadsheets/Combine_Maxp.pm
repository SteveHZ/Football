package Football::Spreadsheets::Combine_Maxp;

use MyRole;
use MyLib qw(build_aoh);

requires qw(add_worksheet do_header write_row);

sub do_maxp ($self, $data, $files) {
    my @keys = qw(homes aways);
	$self->blank_columns ( [ qw(1 3 5 7 9 11 13) ] );

    for my $file (@$files) {
        for my $key (@keys) {
			my $sheetname = $file->{name}.' '.ucfirst $key;
            my $worksheet = $self->add_worksheet ($sheetname);
			my $formats = $self->get_maxp_formats ();
            $self->do_header ($worksheet, $self->{bold_format});

            my $row = 2;
            for my $team_data ( $data->{$sheetname}->@* ) {
				my $row_data = $self->do_maxp_formats ($team_data, $formats);
                $self->write_row ($worksheet, $row, $row_data);
                $row ++;
            }
        }
    }
}

sub get_maxp_formats ($self) {
	my @formats = (
        $self->{format}, $self->{currency_format}, $self->{percent_format},
    );
	my @formats_idx = qw(0 0 1 1 1 1 2 2);

    return [
        map { $formats [$_] } @formats_idx
    ];
}

sub do_maxp_formats ($self, $data, $formats) {
	my $idx = 0;
    return build_aoh ($data, $formats)
}

1;
