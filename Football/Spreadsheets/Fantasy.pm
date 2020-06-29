package Football::Spreadsheets::Fantasy;

use strict;
use warnings;

use utf8;
use Moo;
use namespace::clean;

has 'filename' => (is => 'ro');
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->{filename} = "C:/Mine/perl/Football/reports/fantasy.xlsx";
    $self->{sheets} = $args->{sheets};
}

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
    for my $position ( $self->{sheets}->@* ) {
        my $worksheet = $self->add_worksheet ($position);
    	$self->do_header ($worksheet, $self->{bold_format});

        my $row = 2;
        for my $player ( $sorted->{$position}->@* ) {
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

1;
