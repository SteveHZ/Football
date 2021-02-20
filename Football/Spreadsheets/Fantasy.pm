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
	$worksheet->write ('G1', 'News', $format);
	
	$worksheet->set_column ('A:A', 35, $self->{format} );
    $worksheet->set_column ('B:B', 20, $self->{format} );
    $worksheet->set_column ('C:C', 12, $self->{format} );
    $worksheet->set_column ('D:D', 10, $self->{format} );
    $worksheet->set_column ('E:E', 10, $self->{format} );
    $worksheet->set_column ('F:F', 15, $self->{format} );
	$worksheet->set_column ('G:G', 50, $self->{format} );
}

sub write {
	my ($self, $sorted) = @_;
    for my $position ( $self->{sheets}->@* ) {
        my $worksheet = $self->add_worksheet ($position);
    	$self->do_header ($worksheet, $self->{bold_format});

        my $row = 2;
        for my $player ( $sorted->{$position}->@* ) {
            my $row_data = [
                { $player->{name} => $self->{format} },
                { $player->{team} => $self->{format} },
                { $position => $self->{format} },
                { $player->{price} => $self->{curency_format} },
                { $player->{total_points} => $self->{float_format} },
                { $player->{points_per_game} => $self->{float_format} },
				{ $player->{news} => $self->{format} },
            ];
            $self->write_row ($worksheet, $row, $row_data);
			$row ++;
        }
    }
}

1;
