package Football::Spreadsheets::Match_Odds_View;

use Football::Globals qw($reports_folder @csv_leagues);
use List::MoreUtils qw(each_arrayref);
use List::Util qw (any);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet';

sub BUILD {
	my ($self, $args) = @_;
	$self->create_sheet ();
	$self->{sheet_names} = ['Home Win', 'Draw', 'Away Win', 'Over 2.5', 'Under 2.5', 'Home Double', 'Away Double', 'BSTS Yes', 'BSTS No'];
	$self->{sorted_by} = ['home_win', 'draw', 'away_win', 'over_2pt5', 'under_2pt5', 'home_double', 'away_double', 'both_sides_yes', 'both_sides_no'];

	$self->{dispatch} = { # $self, $game
		home_win		=> sub { $_[0]->get_1x2_rows ($_[1]) },
		draw			=> sub { $_[0]->get_1x2_rows ($_[1]) },
		away_win		=> sub { $_[0]->get_1x2_rows ($_[1]) },
		over_2pt5		=> sub { $_[0]->get_over_under_rows ($_[1]) },
		under_2pt5		=> sub { $_[0]->get_over_under_rows ($_[1]) },
		home_double		=> sub { $_[0]->get_double_chance_rows ($_[1]) },
		away_double		=> sub { $_[0]->get_double_chance_rows ($_[1]) },
		both_sides_yes	=> sub { $_[0]->get_bsts_rows ($_[1]) },
		both_sides_no	=> sub { $_[0]->get_bsts_rows ($_[1]) },
	};

# recent match odds are sorted by season match odds home win !!
	$self->{headers} = { # $self, $worksheet, $format
		home_win	=> sub { $_[0]->do_1x2_header ($_[1], $_[2]) },
		draw		=> sub { $_[0]->do_1x2_header ($_[1], $_[2]) },
		away_win	=> sub { $_[0]->do_1x2_header ($_[1], $_[2]) },
		over_2pt5	=> sub { $_[0]->do_over_under_header ($_[1], $_[2]) },
		under_2pt5	=> sub { $_[0]->do_over_under_header ($_[1], $_[2]) },
		home_double	=> sub { $_[0]->do_double_chance_header ($_[1], $_[2]) },
		away_double	=> sub { $_[0]->do_double_chance_header ($_[1], $_[2]) },
		both_sides_yes	=> sub { $_[0]->do_bsts_header ($_[1], $_[2]) },
		both_sides_no	=> sub { $_[0]->do_bsts_header ($_[1], $_[2]) },
	};

    $self->{blank_cols} = {
        1x2         	=> [ qw( 1 3 5 9 12 15 ) ],
		other_sheets   	=> [ qw( 1 3 5 9 ) ],
    };
}

sub create_sheet {
	my $self = shift;
	$self->{filename} = "$reports_folder/Match Odds UK.xlsx";
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
	my ($self, $fixtures) = @_;
	for my $game ( $fixtures->{over_2pt5}->@* ) {
		print "\n\n".$self->get_csv_league ($game->{league_idx});
		print " : $game->{home_team} v $game->{away_team}";
		print "\nHome Win : ".$game->{odds}->{season}->{home_win};
		print ' Draw : '. $game->{odds}->{season}->{draw};
		print ' Away Win : '. $game->{odds}->{season}->{away_win};
		print ' Both Sides Yes : '. $game->{odds}->{season}->{both_sides_yes};
		print ' Both Sides No : '. $game->{odds}->{season}->{both_sides_no};
		print ' Home Double : '. $game->{odds}->{season}->{home_double};
		print ' Away Double : '. $game->{odds}->{season}->{away_double};
		print ' Over 2.5 : '. $game->{odds}->{season}->{over_2pt5};
		print ' Under 2.5 : '. $game->{odds}->{season}->{under_2pt5};
	}
	$self->do_match_odds ($fixtures);
}

sub get_csv_league {
	my ($self, $league_idx) = @_;
	return $csv_leagues [$league_idx];
}

sub do_match_odds {
	my ($self, $fixtures) = @_;

	my $iterator = each_arrayref ($self->{sheet_names}, $self->{sorted_by});
	while (my ($sheet_name, $sorted_by) = $iterator->() ) {
		my $worksheet = $self->add_worksheet ($sheet_name);
		$self->{headers}->{$sorted_by}->($self, $worksheet, $self->{format});

		my $row = 2;
		for my $game ($fixtures->{$sorted_by}->@*) {
			my $row_data = $self->{dispatch}->{$sorted_by}->($self, $game); # , $row + 1
			$self->write_row ($worksheet, $row, $row_data);
			$row ++;
		}
	}
}

sub get_1x2_rows {
	my ($self, $game) = @_;
	return [
		$self->match_rows ($game),
		$self->hwd_rows ($game),
		$self->over_under_rows ($game),
		$self->double_rows ($game),
		$self->bsts_rows ($game),
	];
}

sub get_over_under_rows {
	my ($self, $game) = @_;
	return [
		$self->match_rows ($game),
		$self->hwd_rows ($game),
		$self->over_under_rows ($game),
	];
}

sub get_double_chance_rows {
	my ($self, $game) = @_;
	return [
		$self->match_rows ($game),
		$self->hwd_rows ($game),
		$self->double_rows ($game),
	];
}

sub get_bsts_rows {
	my ($self, $game) = @_;
	return [
		$self->match_rows ($game),
		$self->hwd_rows ($game),
		$self->bsts_rows ($game),
	];
}

#	Can be overridden by child classes
sub match_rows {
	my ($self, $game) = @_;
	return
		{ $game->{league} => $self->{format} },
		{ $game->{home_team} => $self->get_format ( $game->{expected_goal_diff} * -1 ) },
		{ $game->{away_team} => $self->get_format ( $game->{expected_goal_diff} ) },
}

#	Can be overridden by child classes
sub hwd_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{season}->{home_win} => $self->{float_format} },
		{ $game->{odds}->{season}->{draw} => $self->{float_format} },
		{ $game->{odds}->{season}->{away_win} => $self->{float_format} },
}

#	Can be overridden by child classes
sub over_under_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{season}->{over_2pt5} => $self->{float_format} },
		{ $game->{odds}->{season}->{under_2pt5} => $self->{float_format} },
}

#	Can be overridden by child classes
sub double_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{season}->{home_double} => $self->{float_format} },
		{ $game->{odds}->{season}->{away_double} => $self->{float_format} },
}

#	Can be overridden by child classes
sub bsts_rows {
	my ($self, $game) = @_;
	return
		{ $game->{odds}->{season}->{both_sides_yes} => $self->{float_format} },
		{ $game->{odds}->{season}->{both_sides_no} => $self->{float_format} },
}

sub get_format {
	my ($self, $goal_diff) = @_;
	return ($goal_diff >= 0) ? $self->{float_format}
							 : $self->{bold_float_format};
}

sub do_1x2_header {
	my ($self, $worksheet, $format) = @_;
	$self->blank_columns ($self->{blank_cols}->{1x2});

	$worksheet->set_column ($_, 25) for (qw (A:A C:C E:E));
	$worksheet->set_column ($_, 10) for (qw (G:I K:L));
	$worksheet->set_column ($_, 12) for (qw (N:O));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F J:J M:M P:P));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);

	$worksheet->write ('G1', 'Home Win', $format);
	$worksheet->write ('H1', 'Draw', $format);
	$worksheet->write ('I1', 'Away Win', $format);

	$worksheet->write ('K1', 'Over 2.5', $format);
	$worksheet->write ('L1', 'Under 2.5', $format);
	$worksheet->write ('N1', 'Home Double', $format);
	$worksheet->write ('O1', 'Away Double', $format);
	$worksheet->write ('Q1', 'BSTS Yes', $format);
	$worksheet->write ('R1', 'BSTS No', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_over_under_header {
	my ($self, $worksheet, $format) = @_;
	$self->blank_columns ($self->{blank_cols}->{other_sheets});

	$worksheet->set_column ($_, 25) for (qw (A:A C:C E:E N:N));
	$worksheet->set_column ($_, 10) for (qw (G:I K:L));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F J:J M:M));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);

	$worksheet->write ('G1', 'Home Win', $format);
	$worksheet->write ('H1', 'Draw', $format);
	$worksheet->write ('I1', 'Away Win', $format);

	$worksheet->write ('K1', 'Over 2.5', $format);
	$worksheet->write ('L1', 'Under 2.5', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_double_chance_header {
	my ($self, $worksheet, $format) = @_;
	$self->blank_columns ($self->{blank_cols}->{other_sheets});

	$worksheet->set_column ($_, 25) for (qw (A:A C:C E:E N:N));
	$worksheet->set_column ($_, 10) for (qw (G:I));
	$worksheet->set_column ($_, 12) for (qw (K:L));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F J:J M:M));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);

	$worksheet->write ('G1', 'Home Win', $format);
	$worksheet->write ('H1', 'Draw', $format);
	$worksheet->write ('I1', 'Away Win', $format);

	$worksheet->write ('K1', 'Home Double', $format);
	$worksheet->write ('L1', 'Away Double', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

sub do_bsts_header {
	my ($self, $worksheet, $format) = @_;
	$self->blank_columns ($self->{blank_cols}->{other_sheets});

	$worksheet->set_column ($_, 25) for (qw (A:A C:C E:E N:N));
	$worksheet->set_column ($_, 10) for (qw (G:I K:L));
	$worksheet->set_column ($_, 2.5) for (qw (B:B D:D F:F J:J M:M));

	$worksheet->write ('A1', 'League', $format);
	$worksheet->write ('C1', 'Home', $format);
	$worksheet->write ('E1', 'Away', $format);

	$worksheet->write ('G1', 'Home Win', $format);
	$worksheet->write ('H1', 'Draw', $format);
	$worksheet->write ('I1', 'Away Win', $format);

	$worksheet->write ('K1', 'BSTS Yes', $format);
	$worksheet->write ('L1', 'BSTS No', $format);

	$worksheet->autofilter( 'A1:A100' );
	$worksheet->freeze_panes (1,0);
}

=begin comment
	$self->{dispatch} = {
		home_win		=> sub { my $self = shift; $self->get_1x2_rows (@_) },
		draw			=> sub { my $self = shift; $self->get_1x2_rows (@_) },
		away_win		=> sub { my $self = shift; $self->get_1x2_rows (@_) },
		over_2pt5		=> sub { my $self = shift; $self->get_over_under_rows (@_) },
		under_2pt5		=> sub { my $self = shift; $self->get_over_under_rows (@_) },
		home_double		=> sub { my $self = shift; $self->get_double_chance_rows (@_) },
		away_double		=> sub { my $self = shift; $self->get_double_chance_rows (@_) },
		both_sides_yes	=> sub { my $self = shift; $self->get_bsts_rows (@_) },
		both_sides_no	=> sub { my $self = shift; $self->get_bsts_rows (@_) },
	};

	$self->{headers} = {
		home_win	=> sub { my $self = shift; $self->do_1x2_header (@_) },
		draw		=> sub { my $self = shift; $self->do_1x2_header (@_) },
		away_win	=> sub { my $self = shift; $self->do_1x2_header (@_) },
		over_2pt5	=> sub { my $self = shift; $self->do_over_under_header (@_) },
		under_2pt5	=> sub { my $self = shift; $self->do_over_under_header (@_) },
		home_double	=> sub { my $self = shift; $self->do_double_chance_header (@_) },
		away_double	=> sub { my $self = shift; $self->do_double_chance_header (@_) },
		both_sides_yes	=> sub { my $self = shift; $self->do_bsts_header (@_) },
		both_sides_no	=> sub { my $self = shift; $self->do_bsts_header (@_) },
	};
=end comment
=cut

1;
