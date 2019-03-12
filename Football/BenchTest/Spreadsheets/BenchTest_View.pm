package Football::BenchTest::Spreadsheets::BenchTest_View;

use strict;
use warnings;
use List::MoreUtils qw(each_arrayref);
use utf8;

use Football::BenchTest::Goal_Expect_Model;
use Football::BenchTest::Over_Under_Model;
use Football::BenchTest::OU_Points_Model;

use Moo;
use namespace::clean;

has 'filename' => (is => 'ro', default => 'C:/Mine/perl/Football/reports/benchtest.xlsx');
with 'Roles::Spreadsheet';

sub BUILD {
    my $self = shift;
    $self->{sheetnames} = [ 'Goal Expects', 'Goal Diffs', 'Over Unders', 'OU Points' ];
    $self->{headings} = {
        'Goal Expects'  => ['Home Away', 'Last Six', 'HA Last Six'],
        'Over Unders'   => ['Home Away', 'Last Six', 'HA Last Six'],
        'Goal Diffs'    => ['Home Away', 'Last Six', 'HA Last Six'],
        'OU Points'     => ['Overs', 'Unders'],
    };
    $self->{keys} = {
        'Goal Expects'  => [ qw(home_away last_six ha_lsx) ],
        'Over Unders'   => [ qw(ou_home_away ou_last_six ou_ha_lsx) ],
        'Goal Diffs'    => [ qw(gd_home_away gd_last_six gd_ha_lsx) ],
        'OU Points'     => [ qw(ou_points ou_points) ],
    };
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
    my ($self, $totals) = @_;
    print "\n\nWriting $self->{filename}...";

    $self->blank_columns ( [ 3 ] );
    for my $sheet (@{ $self->{sheetnames} }) {
        my $worksheet = $self->add_worksheet ($sheet);
        my $iterator = each_arrayref ($self->{headings}->{$sheet}, $self->{keys}->{$sheet});
        my $row = 0;

        while (my ($header, $key) = $iterator->() ) {
            $worksheet->write ($row++, 1, uc $header, $self->{format});
            $self->{dispatch}->{$sheet}->($self, $worksheet, $totals, $key, \$row, $header);
            $row ++;
        }
    }
}

#   Called by $self->{dispatch}

sub do_expects {
    my ($self, $worksheet, $totals, $key, $row) = @_;
    my $model = Football::BenchTest::Goal_Expect_Model->new ();
    my $range = $model->range;

    for my $i (@$range) {
        my $hashref = $totals->{$key}->{$i};
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
    my ($self, $worksheet, $totals, $key, $row) = @_;
    my $model = Football::BenchTest::Over_Under_Model->new ();
    my $range = $model->range;

    for my $i (@$range) {
        my $hashref = $totals->{$key}->{$i};

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
    my ($self, $worksheet, $totals, $key, $row, $header) = @_;
    my $model = Football::BenchTest::OU_Points_Model->new ();
    my $range = ($header eq 'Overs')
        ? $model->over_range : $model->under_range;

    for my $i (@$range) {
        my $hashref = $totals->{$key}->{$i};

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

1;
