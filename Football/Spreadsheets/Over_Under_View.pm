package Football::Spreadsheets::Over_Under_View;

#	Football::Spreadsheets::Over_Under_View.pm 26/07/17

use List::MoreUtils qw(each_arrayref);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet',
'Football::Roles::Signed'; # _show_signed


sub BUILD {
	my $self = shift;

	$self->create_sheet ();
	$self->{sheet_names} = ['Over Under', 'Home and Away', 'Last Six', 'OU Points', 'OU Points2', 'OU Unders',];
	$self->{sorted_by} = ['ou_odds', 'ou_home_away', 'ou_last_six', 'ou_points','ou_points2', 'ou_unders'];

	$self->{dispatch} = {
		ou_odds 		=> sub { my $self = shift; $self->get_over_under_rows (@_) },
		ou_home_away	=> sub { my $self = shift; $self->get_over_under_rows (@_) },
		ou_last_six 	=> sub { my $self = shift; $self->get_over_under_rows (@_) },
		ou_points 		=> sub { my $self = shift; $self->get_ou_points_rows (@_) },
		ou_points2 		=> sub { my $self = shift; $self->get_ou_points2_rows (@_) },
		ou_unders 		=> sub { my $self = shift; $self->get_unders_rows (@_) },
	};

	$self->{headers} = {
		ou_odds 		=> sub { my $self = shift; $self->do_over_under_header (@_) },
		ou_home_away	=> sub { my $self = shift; $self->do_over_under_header (@_) },
		ou_last_six 	=> sub { my $self = shift; $self->do_over_under_header (@_) },
		ou_points 		=> sub { my $self = shift; $self->do_ou_points_header (@_) },
		ou_points2 		=> sub { my $self = shift; $self->do_ou_points_header (@_) },
		ou_unders 		=> sub { my $self = shift; $self->do_unders_header (@_) },
	};
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = "$path/over_under.xlsx"
		unless defined $self->{filename};
}

after 'BUILD' => sub {
	my $self = shift;

	$self->{blank_text_format} = $self->copy_format ( $self->{format} );
	$self->{blank_text_format}->set_num_format ('@');

	$self->{blank_number_format} = $self->copy_format ( $self-> {blank_text_format} );
	$self->{blank_number_format}->set_num_format ('#0.00');

	$self->{blank_text_format2} = $self->copy_format ( $self->{blank_text_format} );
	$self->{blank_text_format2}->set_color ('black');
	$self->{blank_text_format2}->set_bg_color ('white');

	$self->{blank_number_format2} = $self->copy_format ($self->{blank_text_format2} );
	$self->{blank_number_format2}->set_num_format ('#0.00');

	$self->{bold_float_format} = $self->copy_format ( $self->{float_format} );
	$self->{bold_float_format}->set_color ('orange');
	$self->{bold_float_format}->set_bold ();
};

sub view {
	my ($self, $sorted) = @_;
	my $iterator = each_arrayref ($self->{sheet_names}, $self->{sorted_by});

	while (my ($sheet_name, $sorted_by) = $iterator->() ) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		$self->{headers}->{$sorted_by}->($self, $worksheet, $self->{format});

		my $row = 2;
		for my $game ( $sorted->{$sorted_by}->@* ) {
			$self->blank_columns ( [ qw( 1 3 5 8 10 13 15) ] );

			my $row_data = $self->{dispatch}->{$sorted_by}->($self, $game);
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

#	called by $self->{dispatch}

sub get_over_under_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },

		{ $game->{home_over_under} => $self->{format} },
		{ $game->{away_over_under} => $self->{format} },
		{ $game->{home_away} => $self->{percent_format} },

		{ $game->{home_last_six_over_under} => $self->{format} },
		{ $game->{away_last_six_over_under} => $self->{format} },
		{ $game->{last_six} => $self->{percent_format} },

		{ $game->{odds}->{last_six}->{over_2pt5} => $self->{float_format} },
		{ $game->{odds}->{last_six}->{under_2pt5} => $self->{float_format} },
	];
}

sub get_ou_points_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },
		{ $game->{ou_points} => $self->{float_format} },
	];
}

sub get_ou_points2_rows {
	my ($self, $game) = @_;
	return [
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->{format} },
		{ $game->{away_team} => $self->{format} },
		{ $game->{ou_points2} => $self->{float_format} },
	];
}

sub get_unders_rows {
	my ($self, $team) = @_;
	return [
		{ $team->{league} => $self->{format} },
		{ $team->{team} => $self->{format} },
		{ $team->{goals} => $self->{format} },
	];
}

#	called by $self->{headers}

sub do_over_under_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 20) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 10) for (qw (J:J O:O Q:R));
	$worksheet->set_column ($_, 6) for (qw (G:H L:M));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F I:I K:K N:N P:P));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);
	$worksheet->merge_range ('G1:J1', 'HOMES & AWAYS', $format);
	$worksheet->merge_range ('L1:O1', 'LAST SIX', $format);
	$worksheet->merge_range ('Q1:R1', 'O/U ODDS', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_ou_points_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 20) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 6) for (qw (F:F));
	$worksheet->set_column ($_, 10) for (qw (G:G));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);
	$worksheet->write ('G1', 'Points', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_unders_header {
	my ($self, $worksheet, $format) = @_;

	$worksheet->set_column ($_, 20) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Team', $format);
	$worksheet->write ('E1', 'Goals', $format);

	$worksheet->autofilter( 'A1:A160' );
	$worksheet->freeze_panes (1,0);
}

1;
