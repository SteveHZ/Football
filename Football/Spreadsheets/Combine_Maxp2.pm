package Football::Spreadsheets::Combine_Maxp2;

use MyIterators qw(make_circular_iterator);
use Moo::Role;
use namespace::clean;

#requires qw(add_worksheet do_header write_row);
requires qw(add_worksheet write_row);

sub do_maxp {
	my ($self, $data, $files) = @_;
    my @keys = qw(homes aways);
    my $iterator = make_circular_iterator ($self->get_maxp_format ());

    for my $file (@$files) {
        for my $key (@keys) {
            my $sheetname = $file->{name}.' '.ucfirst $key;
            my $worksheet = $self->add_worksheet ($sheetname);
            $self->do_header ($worksheet, $self->{bold_format});

            my $row = 2;
            for my $team (@{ $data->{ $file->{name} }->{$key} } ) {
                my $row_data = get_row_data ($team, $iterator);
                $self->write_row ($worksheet, $row, $row_data);
                $row ++;
            }
        }
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
