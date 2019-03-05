package Football::BenchTest::Spreadsheets::BenchTest_View;

use strict;
use warnings;
use List::MoreUtils qw(each_arrayref);
use utf8;

use Moo;
use namespace::clean;

has 'filename' => (is => 'ro', default => 'C:/Mine/perl/Football/reports/benchtest.xlsx');
with 'Roles::Spreadsheet';

sub BUILD {
    my $self = shift;
#    $self->{sheetnames} = [ 'Goal Expects', 'Goal Diffs' ];
    $self->{sheetnames} = [ 'Goal Expects', 'Over Unders', 'Goal Diffs' ];
    $self->{headings} = {
        'Goal Expects'  => ['Home Away', 'Last Six', 'HA Last Six'],
        'Over Unders'   => ['Home Away', 'Last Six', 'HA Last Six'],
#        'Over Unders'   => ['Home Away', 'Last Six', 'HA Last Six', 'OU Points'],
        'Goal Diffs'  => ['Home Away', 'Last Six', 'HA Last Six'],
    };
    $self->{keys} = {
        'Goal Expects'  => [ qw(home_away last_six ha_lsx) ],
        'Over Unders'   => [ qw(ou_home_away ou_last_six ou_ha_lsx) ],
#        'Over Unders'   => [ qw(ou_home_away ou_last_six ou_ha_lsx ou_points) ],
        'Goal Diffs'  => [ qw(gd_home_away gd_last_six gd_ha_lsx) ],
    };
    $self->{dispatch} = {
        'Goal Expects'	=> \&Football::BenchTest::Spreadsheets::BenchTest_View::do_expects,
        'Over Unders'	=> \&Football::BenchTest::Spreadsheets::BenchTest_View::do_over_unders,
        'Goal Diffs'	=> \&Football::BenchTest::Spreadsheets::BenchTest_View::do_expects,
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

    $self->blank_columns ( [ qw( 3 7 8 10 13 ) ] );
    for my $sheet (@{ $self->{sheetnames} }) {
        my $worksheet = $self->add_worksheet ($sheet);
        my $iterator = each_arrayref ($self->{headings}->{$sheet}, $self->{keys}->{$sheet});
        my $row = 0;

        while (my ($header, $key) = $iterator->() ) {
            $worksheet->write ($row++, 1, uc $header, $self->{format});
            $self->{dispatch}->{$sheet}->($self, $worksheet, $totals, $key, \$row);
            $row ++;
        }
    }
}

#   Called by $self->{dispatch}

sub do_expects {
    my ($self, $worksheet, $totals, $key, $row) = @_;

    for (my $i = 0; $i <= 3; $i += 0.5) {
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
    my @range;
    if ($key eq 'ou_points')    { @range = (5,6,7,8,9,10) }
    else                        { @range = (0.5,0.6,0.7,0.8,0.9,1) }

    for my $i (@range) {
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
