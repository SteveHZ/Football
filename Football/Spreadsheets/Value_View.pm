package Football::Spreadsheets::Value_View;

use List::MoreUtils qw(each_arrayref);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
has 'overround' => (is => 'ro', default => 1.05);
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;

	$self->create_sheet ();
	$self->{sheet_names} = ['Home Win', 'Away Win', 'Draw', 'Over 2.5', 'Under 2.5'];
	$self->{sorted_by} = ['home_win', 'away_win', 'draw', 'over_2pt5', 'under_2pt5'];

    $self->{dispatch} = {
		home_win      => sub { my $self = shift; $self->get_1x2_rows (@_) },
		away_win      => sub { my $self = shift; $self->get_1x2_rows (@_) },
		draw          => sub { my $self = shift; $self->get_get_1x2_rows (@_) },
		over_2pt5     => sub { my $self = shift; $self->get_over_under_rows (@_) },
		under_2pt5    => sub { my $self = shift; $self->get_over_under_rows (@_) },
	};

	$self->{headers} = {
		home_win      => sub { my $self = shift; $self->do_1x2_header (@_) },
		away_win      => sub { my $self = shift; $self->do_1x2_header (@_) },
		draw          => sub { my $self = shift; $self->do_1x2_header (@_) },
		over_2pt5     => sub { my $self = shift; $self->do_over_under_header (@_) },
		under_2pt5    => sub { my $self = shift; $self->do_over_under_header (@_) },
	};

    $self->{blank_cols} = {
        1x2         => [ qw( 1 3 5 9 ) ],
        over_under  => [ qw ( 1 3 5 8 11 ) ],
    };
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'value.xlsx';
}

sub view {
	my ($self, $sorted) = @_;
	my $iterator = each_arrayref ($self->{sheet_names}, $self->{sorted_by});

	while (my ($sheet_name, $sorted_by) = $iterator->() ) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		$self->{headers}->{$sorted_by}->($self, $worksheet, $self->{format});

		my $row = 2;
		for my $game (@{ $sorted->{$sorted_by} } ) {
			my $row_data = $self->{dispatch}->{$sorted_by}->($self, $game);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

#	called by $self->{dispatch}

sub get_1x2_rows {
	my ($self, $game) = @_;
    $self->blank_columns ($self->{blank_cols}->{1x2});

	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },

		{ $game->{home_win} => $self->{float_format} },
        { $game->{draw} => $self->{float_format} },
        { $game->{away_win} => $self->{float_format} },

        { $game->{fdata}->{home_win} => $self->{float_format} },
        { $game->{fdata}->{draw} => $self->{float_format} },
        { $game->{fdata}->{away_win} => $self->{float_format} },
	];
}

sub get_over_under_rows {
	my ($self, $game) = @_;
    $self->blank_columns ($self->{blank_cols}->{over_under});

	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },

		{ $game->{over_2pt5} => $self->{float_format} },
		{ $game->{under_2pt5} => $self->{float_format} },

        { $game->{fdata}->{over_2pt5} => $self->{float_format} },
		{ $game->{fdata}->{under_2pt5} => $self->{float_format} },

        { $game->{over_2pt5} * $self->{overround} => $self->{float_format} },
		{ $game->{under_2pt5} * $self->{overround} => $self->{float_format} },
	];
}

#	called by $self->{headers}

sub do_1x2_header {
	my ($self, $worksheet, $format) = @_;
    $self->blank_columns ($self->{blank_cols}->{1x2});

	$worksheet->set_column ($_, 20) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 6) for (qw (F:F));
	$worksheet->set_column ($_, 10) for (qw (G:I K:M));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);
    $worksheet->merge_range ('G1:I1', 'MINE', $format);
    $worksheet->merge_range ('K1:M1', 'FOOTBALL DATA', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_over_under_header {
	my ($self, $worksheet, $format) = @_;
    $self->blank_columns ($self->{blank_cols}->{over_under});

	$worksheet->set_column ($_, 20) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 10) for (qw (G:H J:K M:N));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F I:I));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);
    $worksheet->merge_range ('G1:H1', 'MINE', $format);
    $worksheet->merge_range ('J1:K1', 'FOOTBALL DATA', $format);
    $worksheet->merge_range ('M1:N1', 'FOOTBALL DATA', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

1;
