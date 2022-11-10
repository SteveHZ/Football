package Football::Spreadsheets::Fantasy;

use utf8;
use Football::Globals qw ($reports_folder);

use Moo;
use namespace::clean;

has 'filename' => (is => 'ro');
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->{filename} = "$reports_folder/fantasy.xlsx";
    $self->{sheets} = $args->{sheets};
}

after 'BUILD' => sub {
	my $self = shift;

	$self->{blank_text_format} = $self->copy_format ( $self->{format} );
	$self->{blank_text_format}->set_color ('black');
	$self->{blank_text_format}->set_bg_color ('white');
};

sub do_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->write ('A1', 'Name', $format);
    $worksheet->write ('B1', 'Team', $format);

    $worksheet->write ('D1', 'Price', $format);
    $worksheet->write ('E1', 'Total Points', $format);
    $worksheet->write ('F1', 'Points per Game', $format);
	$worksheet->write ('G1', 'Minutes', $format);

	$worksheet->merge_range ('I1:J1', 'Ranking', $format);
	$worksheet->write ('L1', 'Value', $format);
	$worksheet->write ('N1', 'News', $format);
	
	$worksheet->set_column ('A:A', 35, $self->{format} );
    $worksheet->set_column ('B:B', 20, $self->{format} );
	$worksheet->set_column ('C:C',  2, $self->{blank_text_format} );

    $worksheet->set_column ('D:E', 10, $self->{format} );
    $worksheet->set_column ('F:F', 15, $self->{format} );
    $worksheet->set_column ('G:G', 10, $self->{format} );
	$worksheet->set_column ('H:H',  2, $self->{blank_text_format} );

    $worksheet->set_column ('I:J',  8, $self->{format} );
	$worksheet->set_column ('K:K',  2, $self->{blank_text_format} );
    $worksheet->set_column ('L:L',  8, $self->{format} );
	$worksheet->set_column ('M:M',  2, $self->{blank_text_format} );
	$worksheet->set_column ('N:N', 50, $self->{blank_text_format} );
}

sub write {
	my ($self, $sorted) = @_;
    for my $position ( $self->{sheets}->@* ) {
        my $worksheet = $self->add_worksheet ($position);
    	$self->do_header ($worksheet, $self->{bold_format});
		$self->blank_columns ( [ qw (2 7 10 12)]);

        my $row = 2;
        for my $player ( $sorted->{$position}->@* ) {
            my $row_data = [
                { $player->{name} => $self->{format} },
                { $player->{team} => $self->{format} },
                { $player->{price} => $self->{format} },
                { $player->{total_points} => $self->{float_format} },
                { $player->{points_per_game} => $self->{float_format} },
				{ $player->{minutes} => $self->{format} },
				{ $player->{ict_index_rank_type} => $self->{format} },
				{ $player->{ict_index_rank} => $self->{format} },
				{ $player->{value} => $self->{format} },
				{ $player->{news} => $self->{blank_text_format} },
            ];
            $self->write_row ($worksheet, $row, $row_data);
			$row ++;
        }
    }
	print "\nFinished writing $self->{filename}...\n";
}

1;
