package Football::BenchTest::Spreadsheets::BenchTest_View;

use strict;
use warnings;
use List::MoreUtils qw(each_arrayref);
use utf8;

use Moo;
use namespace::clean;

has 'models' => (is => 'ro');
has 'filename' => (is => 'ro', default => 'C:/Mine/perl/Football/reports/benchtest.xlsx');
with 'Roles::Spreadsheet';

sub BUILD {
    my $self = shift;
    $self->{dispatch} = {
        'Goal Expects'	=> \&Football::BenchTest::Spreadsheets::BenchTest_View::do_expects,
        'Goal Diffs'	=> \&Football::BenchTest::Spreadsheets::BenchTest_View::do_expects,
        'Over Unders'	=> \&Football::BenchTest::Spreadsheets::BenchTest_View::do_over_unders,
        'OU Points'     => \&Football::BenchTest::Spreadsheets::BenchTest_View::do_ou_points,
    };
}

after 'BUILD' => sub {
    my $self = shift;
    $self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
    $self->{bold_float_format}->set_color ('orange');
    $self->{bold_float_format}->set_bold ();
};

sub write {
    my $self = shift;
    print "\n\nWriting $self->{filename}...";

    $self->blank_columns ( [ 3 ] );
    for my $model (@{ $self->models}) {
        my $counter = $model->counter;
        my $sheetname = $model->sheetname;
        my $worksheet = $self->add_worksheet ($sheetname);
        my $row = 0;

        my $iterator = each_arrayref ($model->headings, $model->keys);
        while (my ($header, $key) = $iterator->() ) {
            $worksheet->write ($row++, 1, uc $header, $self->{format});
            $self->{dispatch}->{$sheetname}->($self, $worksheet, $model, $counter, $key, \$row, $header);
            $row ++;
        }
    }
}

#   Called by $self->{dispatch}

sub do_expects {
    my ($self, $worksheet, $model, $counter, $key, $row) = @_;

    for my $i (@{ $model->range }) {
        my ($wins, $from) = $counter->get_data ($key, $i);
        my $percent = ($from == 0) ? 0 : $wins / $from;

        my $row_data = [
            { $i        => $self->{bold_float_format} },
            { $wins     => $self->{format} },
            { $from     => $self->{format} },
            { $percent  => $self->{percent_format} },
        ];
        $self->write_row ($worksheet, $$row, $row_data);
        $$row ++;
    }
}

sub do_over_unders {
    my ($self, $worksheet, $model, $counter, $key, $row) = @_;

    for my $i (@{ $model->range }) {
        my ($wins, $from) = $counter->get_data ($key, $i);
        my $percent = ($from == 0) ? 0 : $wins / $from;

        my $row_data = [
            { $i        => $self->{bold_float_format} },
            { $wins     => $self->{format} },
            { $from     => $self->{format} },
            { $percent  => $self->{percent_format} },
        ];
        $self->write_row ($worksheet, $$row, $row_data);
        $$row ++;
    }
}

sub do_ou_points {
    my ($self, $worksheet, $model, $counter, $key, $row, $header) = @_;
    my $range = ($header eq 'Overs')
        ? $model->over_range : $model->under_range;

        for my $i (@$range) {
            my ($wins, $from) = $counter->get_data ($key, $i);
            my $percent = ($from == 0) ? 0 : $wins / $from;

            my $row_data = [
                { $i        => $self->{bold_float_format} },
                { $wins     => $self->{format} },
                { $from     => $self->{format} },
                { $percent  => $self->{percent_format} },
            ];
            $self->write_row ($worksheet, $$row, $row_data);
            $$row ++;
        }
    }

=head
sub do_expects {
    my ($self, $worksheet, $counter, $key, $row) = @_;
    my $model = Football::BenchTest::Goal_Expect_Model->new ();
    my $range = $model->range;

    for my $i (@$range) {
# should have accessors in Counter, cant access from $hashref ??
        my $hashref = $counter->{$key}->{$i};
        my $percent = ($hashref->{from} == 0) ? 0 : $hashref->{wins} / $hashref->{from};
        my $row_data = [
            { $i => $self->{bold_float_format} },
            { $hashref->{wins} => $self->{format} },
            { $hashref->{from} => $self->{format} },
            { $percent => $self->{percent_format} },
        ];
        $self->write_row ($worksheet, $$row, $row_data);
        $$row ++;
    }
}
sub do_over_unders {
    my ($self, $worksheet, $counter, $key, $row) = @_;
    my $model = Football::BenchTest::Over_Under_Model->new ();
    my $range = $model->range;

    for my $i (@$range) {
        my $hashref = $counter->{$key}->{$i};

        my $percent = ($hashref->{from} == 0) ? 0 : $hashref->{wins} / $hashref->{from};
        my $row_data = [
            { $i => $self->{bold_float_format} },
            { $hashref->{wins} => $self->{format} },
            { $hashref->{from} => $self->{format} },
            { $percent => $self->{percent_format} },
        ];
        $self->write_row ($worksheet, $$row, $row_data);
        $$row ++;
    }
}

sub do_ou_points {
    my ($self, $worksheet, $counter, $key, $row, $header) = @_;
    my $model = Football::BenchTest::OU_Points_Model->new ();
    my $range = ($header eq 'Overs')
        ? $model->over_range : $model->under_range;

    for my $i (@$range) {
        my $hashref = $counter->{$key}->{$i};

        my $percent = ($hashref->{from} == 0) ? 0 : $hashref->{wins} / $hashref->{from};
        my $row_data = [
            { $i => $self->{bold_float_format} },
            { $hashref->{wins} => $self->{format} },
            { $hashref->{from} => $self->{format} },
            { $percent => $self->{percent_format} },
        ];
        $self->write_row ($worksheet, $$row, $row_data);
        $$row ++;
    }
}
=cut

1;
