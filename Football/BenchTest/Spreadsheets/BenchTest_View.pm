package Football::BenchTest::Spreadsheets::BenchTest_View;

use strict;
use warnings;
#use Data::Dumper;
use List::MoreUtils qw(each_arrayref);

use utf8;
use Moo;
use namespace::clean;

has 'filename' => (is => 'ro', default => 'C:/Mine/perl/Football/reports/benchtest.xlsx');
with 'Roles::Spreadsheet';

sub BUILD {
    my $self = shift;
    $self->{sheets} = ['Home Away', 'Last Six', 'HA Last Six'];
    $self->{keys} = [qw( home_away last_six ha_lsx)];
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

    my $row = 0;
    $self->blank_columns ( [ qw( 3 7 8 10 13 ) ] );
    my $worksheet = $self->add_worksheet ('Goal Expects');

    my $iterator = each_arrayref ($self->{sheets}, $self->{keys});
    while (my ($sheet, $key) = $iterator->() ) {
        $worksheet->write ($row++, 1, uc $sheet, $self->{format});
        for (my $i = 0; $i <= 3; $i += 0.5) {
            my $hashref = $totals->{$key}->{$i};
            my $percent = ($hashref->{from} == 0) ? 0 : $hashref->{wins} / $hashref->{from};
            my $row_data = [
                { $i => $self->{bold_float_format} },
                { $hashref->{wins} => $self->{format} },
                { $hashref->{from} => $self->{format} },
                { $percent => $self->{percent_format} },
            ];
            $self->write_row ($worksheet, $row, $row_data);
            $row ++;
        }
        $row ++;
    }
}

=head
sub write {
	my ($self, $data, $totals) = @_;
    print "\n\nWriting $self->{filename}...";

#    for my $sheet (@{ $self->{sheets} }) {
#        my $worksheet = $self->add_worksheet ($sheet);
#    	$self->do_header ($worksheet, $self->{bold_format});
    my $worksheet = $self->add_worksheet (@{ $self->{sheets} } [0]);
    my $row = 0;
    for my $week (0..$#$data) {
        $self->blank_columns ( [ qw( 3 7 8 10 13 ) ] );
        for (my $i = 0; $i <= 3; $i += 0.5) {
            my $hashref = @$data[$week]->{home_away}->{$i};
            my $percent = ($hashref->{from} == 0) ? 0 : $hashref->{wins} / $hashref->{from};
            my $row_data = [
                { $i => $self->{bold_float_format} },
                { $hashref->{wins} => $self->{format} },
                { $hashref->{from} => $self->{format} },
                { $percent => $self->{percent_format} },
            ];
            $self->write_row ($worksheet, $row, $row_data);
			$row ++;
        }
        $row ++;
    }
    for (my $i = 0; $i <= 3; $i += 0.5) {
        my $hashref = $totals->{home_away}->{$i};
        my $percent = ($hashref->{from} == 0) ? 0 : $hashref->{wins} / $hashref->{from};
        my $row_data = [
            { $i => $self->{bold_float_format} },
            { $hashref->{wins} => $self->{format} },
            { $hashref->{from} => $self->{format} },
            { $percent => $self->{percent_format} },
        ];
        $self->write_row ($worksheet, $row, $row_data);
        $row ++;
    }
}
=cut

=head
                    $results->{home_away}->{$i} = {
                        wins => scalar @{ $expect_model->home_away_wins ($expect_data, $i) },
                        from => scalar @{ $expect_model->home_away_games ($expect_data, $i) },
                    };
                    $results->{last_six}->{$i} = {
                        wins => scalar @{ $expect_model->last_six_wins ($expect_data, $i) },
                        from => scalar @{ $expect_model->last_six_games ($expect_data, $i) },
                    };
                    $results->{ha_lsx}->{$i} = {
                        wins => scalar @{ $expect_model->ha_lsx_wins ($expect_data, $i) },
                        from => scalar @{ $expect_model->ha_lsx_games ($expect_data, $i) },
                    };


#=head

sub do_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->write ('A1', 'Name', $format);
    $worksheet->write ('B1', 'Team', $format);
    $worksheet->write ('C1', 'Position', $format);
    $worksheet->write ('D1', 'Price', $format);
    $worksheet->write ('E1', 'Total Points', $format);
    $worksheet->write ('F1', 'Points per Game', $format);

	$worksheet->set_column ('A:A', 30, $self->{format} );
    $worksheet->set_column ('B:B', 20, $self->{format} );
    $worksheet->set_column ('C:F', 10, $self->{format} );
}

sub write {
	my ($self, $sorted) = @_;
    for my $position (@{ $self->{sheets} } ) {
        my $worksheet = $self->add_worksheet ($position);
    	$self->do_header ($worksheet, $self->{bold_format});

        my $row = 2;
        for my $player (@{ $sorted->{$position} } ) {
            my $row_data = [
                { $player->{name} => $self->{bold_format} },
                { $player->{team} => $self->{bold_format} },
                { $position => $self->{bold_format} },
                { $player->{price} => $self->{curency_format} },
                { $player->{total_points} => $self->{float_format} },
                { $player->{points_per_game} => $self->{float_format} },
            ];
            $self->write_row ($worksheet, $row, $row_data);
			$row ++;
        }
    }
}

#=head
after 'BUILD' => sub {
	my $self = shift;

	$self->{bold_format}->set_color ('blue');
	$self->{currency_format}->set_color ('black');
	$self->{currency_format}->set_bg_color ('white');
	$self->{percent_format}->set_color ('black');
	$self->{percent_format}->set_bg_color ('white');

	$self->{text_format} = $self->{workbook}->add_format (
		align => 'center',
		num_format => '@',
	);
	$self->{date_format} = $self->{workbook}->add_format (
		align => 'center',
		num_format => 'DD/MM/YY',
	);
};
=cut

1;
