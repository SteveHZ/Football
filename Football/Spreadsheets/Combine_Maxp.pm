package Football::Spreadsheets::Combine_Maxp;

use Moo::Role;
use namespace::clean;
with 'Roles::Iterators'; # make_circular_iterator

requires qw(add_worksheet do_header write_row);

sub do_maxp {
	my ($self, $data, $files) = @_;
    my $iterator = make_circular_iterator ($self->get_maxp_format ());

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
