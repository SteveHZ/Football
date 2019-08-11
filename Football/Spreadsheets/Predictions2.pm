package Football::Spreadsheets::Predictions2;

#	Predictions.pm 07/02/16 - 15/03/16
#	v2 14/03/16, v2.1 02/04/17
#	v2.2 06/05/17

use List::MoreUtils qw(each_arrayref);

use Moo;
use namespace::clean;

has 'filename' => ( is => 'ro' );
with 'Roles::Spreadsheet',
	 'Football::Roles::Signed'; # _show_signed

sub BUILD {
	my $self = shift;
#print "\nIn Football::Spreadsheets::Predictions2 !!!";
	$self->create_sheet ();
}

sub create_sheet {
	my $self = shift;
	my $path = 'C:/Mine/perl/Football/reports/';
	$self->{filename} = $path.'predictions.xlsx';
}

sub do_fixtures {
	my ($self, $fixtures) = @_;
	my ($col, $result);
	my $row = 1;

	my $worksheet = $self->add_worksheet (' Homes and Aways ');
	do_fixtures_header ($worksheet, $self->{bold_format});

	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		$worksheet->merge_range (++$row, 0, $row, 15, uc $league_name, $self->{bold_format});
		$row +=2;

		for my $game (@{ $league->{games} } ) {
			$col = 0;
			my $iterator = each_arrayref ( $game->{homes}, $game->{full_homes} );
			while ( my ($result, $full_result) = $iterator->() ) {
				$worksheet->write ($row, $col, $result, $self->{format});
				$worksheet->write_comment ($row, $col++, "$full_result->{date} $full_result->{opponent} \n($full_result->{home_away}) $full_result->{score}");
			}
			$col = 7;
			$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});

			$col ++;
			$iterator = each_arrayref ( $game->{aways}, $game->{full_aways} );
			while ( my ($result, $full_result) = $iterator->() ) {
				$worksheet->write ($row, $col, $result, $self->{format});
				$worksheet->write_comment ($row, $col++, "$full_result->{date} $full_result->{opponent} \n($full_result->{home_away}) $full_result->{score}");
			}
			$col = 17;
			$worksheet->write ($row, $col ++, $game->{home_points}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_points}, $self->{format});
			$row ++;
		}
	}
	$worksheet->freeze_panes (1,0);
}

sub do_last_six {
	my ($self, $fixtures) = @_;
	my ($col, $result);
	my $row = 1;

#
	my $worksheet = $self->add_worksheet (' Last Six Games ');
	do_fixtures_header ($worksheet, $self->{bold_format});

	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		$worksheet->merge_range (++$row, 0, $row, 15, uc $league_name, $self->{bold_format});
		$row +=2;

		for my $game (@{ $league->{games} } ) {
			$col = 0;
#
			my $iterator = each_arrayref ( $game->{home_last_six}, $game->{full_home_last_six} );
			while ( my ($result, $full_result) = $iterator->() ) {
				$worksheet->write ($row, $col, $result, $self->{format});
				$worksheet->write_comment ($row, $col++, "$full_result->{date} $full_result->{opponent} \n($full_result->{home_away}) $full_result->{score}");
			}
			$col = 7;
			$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});

			$col ++;
#
			$iterator = each_arrayref ( $game->{away_last_six}, $game->{full_away_last_six} );
			while ( my ($result, $full_result) = $iterator->() ) {
				$worksheet->write ($row, $col, $result, $self->{format});
				$worksheet->write_comment ($row, $col++, "$full_result->{date} $full_result->{opponent} \n($full_result->{home_away}) $full_result->{score}");
			}
			$col = 17;
#
			$worksheet->write ($row, $col ++, $game->{last_six_home_points}, $self->{format});
#
			$worksheet->write ($row, $col ++, $game->{last_six_away_points}, $self->{format});
			$row ++;
		}
	}
	$worksheet->freeze_panes (1,0);
}

sub do_head2head {
	my ($self, $fixtures) = @_;
	my $row = 1;

#
	my $worksheet = $self->add_worksheet (' Head To Head ');
	do_head2head_header ($worksheet, $self->{bold_format});

	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		$worksheet->merge_range (++$row, 0, $row, 8, uc $league_name, $self->{bold_format});
		$row +=2;

		for my $game (@{ $league->{games} } ) {
			my $col = 0;
			$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});
			$col ++;
			for my $result (@ {$game->{head2head}} ) {
				$worksheet->write ($row, $col ++, $result, $self->{format});
			}
			$col ++;
			$worksheet->write ($row, $col ++, $game->{home_h2h}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_h2h}, $self->{format});
			$row ++;
		}
	}
	$worksheet->freeze_panes (1,0);
}

sub do_recent_goal_difference {
	my ($self, $fixtures) = @_;
	my $row = 1;

	my $worksheet = $self->add_worksheet (' Recent Goal Differences ');
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);
	do_goal_diff_header ($worksheet, $self->{bold_format});

	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		$worksheet->merge_range (++$row, 0, $row, 11, uc $league_name, $self->{bold_format});
		$row +=2;

		for my $game (@{ $league->{games} } ) {
			my $col = 0;
			$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});
			$col += 2;
			$worksheet->write ($row, $col ++, $game->{recent_goal_difference}, $self->{format});
			$col += 2;
			for my $result (@{ $game->{rgd_results}} ) {
				$worksheet->write ($row, $col ++, $result, $self->{format});
				$col ++;
			}
			my $formulae = build_formulae ($row + 1); # 0,0 = A1
			my $per_cent_col = 13;
			for my $formula (@$formulae) {
				$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
			}
			$row ++;
		}
	}
	$worksheet->freeze_panes (1,0);
}

sub do_goal_difference {
	my ($self, $fixtures) = @_;
	my $row = 1;

	my $worksheet = $self->add_worksheet (' Goal Differences ');
	$worksheet->add_write_handler( qr/^-?\d+$/, \&signed_goal_diff);
	do_goal_diff_header ($worksheet, $self->{bold_format});

	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		$worksheet->merge_range (++$row, 0, $row, 11, uc $league_name, $self->{bold_format});
		$row +=2;

		for my $game ( @{$league->{games}} ) {
			my $col = 0;
			$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});
			$col += 2;
#
			$worksheet->write ($row, $col ++, $game->{goal_difference}, $self->{format});
			$col += 2;
#
			for my $result ( @{$game->{gd_results}} ) {
				$worksheet->write ($row, $col ++, $result, $self->{format});
				$col ++;
			}
			my $formulae = build_formulae ($row + 1); # 0,0 = A1
			my $per_cent_col = 13;
			for my $formula (@$formulae) {
				$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
			}
			$row ++;
		}
	}
	$worksheet->freeze_panes (1,0);
}

sub do_league_places {
	my ($self, $fixtures) = @_;
	my $row = 1;

	my $worksheet = $self->add_worksheet (' League Placings ');
	do_league_places_header ($worksheet, $self->{bold_format});

	for my $league (@$fixtures) {
		my $league_name = $league->{league};
		$worksheet->merge_range (++$row, 0, $row, 11, uc $league_name, $self->{bold_format});
		$row +=2;

		for my $game (@{ $league->{games} } ) {
			my $col = 0;
			$worksheet->write ($row, $col ++, $game->{home_team}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_team}, $self->{format});
			$col ++;
			$worksheet->write ($row, $col ++, $game->{home_pos}, $self->{format});
			$worksheet->write ($row, $col ++, $game->{away_pos}, $self->{format});
			$col += 2;
			for my $result (@{ $game->{results}} ) {
				$worksheet->write ($row, $col ++, $result, $self->{format});
				$col ++;
			}
			my $formulae = build_formulae ($row + 1); # 0,0 = A1
			my $per_cent_col = 13;
			for my $formula (@$formulae) {
				$worksheet->write ($row, $per_cent_col ++, $formula, $self->{format});
			}
			$row ++;
		}
	}
	$worksheet->freeze_panes (1,0);
}

sub do_recent_draws {
	my ($self, $draws) = @_;
	my $row = 2;

	my $worksheet = $self->add_worksheet (' Recent Draws ');
	do_recent_draws_header ($worksheet, $self->{bold_format});

	for my $game (@$draws) {
		my $col = 0;
		$worksheet->write ($row, $col ++, $game->{game}->{draws}, $self->{format});
		$col ++;
		$worksheet->write ($row, $col ++, $game->{game}->{home_team}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{game}->{away_team}, $self->{format});
		$col ++;
		$worksheet->write ($row, $col ++, $game->{game}->{home_draws}, $self->{format});
		$worksheet->write ($row, $col ++, $game->{game}->{away_draws}, $self->{format});
		$col ++;
		$worksheet->write ($row, $col ++, $game->{league}, $self->{format});
		$row ++;
	}
	$worksheet->freeze_panes (1,0);
}

sub build_formulae {
	my $row = shift;
	return [
		qq(=IF(SUM(H$row:L$row),(H$row/SUM(H$row:L$row))*100, 0)),
		qq(=IF(SUM(H$row:L$row),(J$row/SUM(H$row:L$row))*100, 0)),
		qq(=IF(SUM(H$row:L$row),(L$row/SUM(H$row:L$row))*100, 0)),
	];
}

sub signed_goal_diff {
	return _show_signed (@_, [ 4 ]);
}

sub do_fixtures_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ($_, 3) for (qw (A:G J:P Q:Q));
	$worksheet->set_column ('H:I', 25);
	$worksheet->set_column ('R:S', 5);

	$worksheet->merge_range ('A1:F1', 'Home results',$format);
	$worksheet->write ('H1', 'Home team', $format);
	$worksheet->write ('I1', 'Away team', $format);
	$worksheet->merge_range ('K1:P1', 'Away results', $format);
	$worksheet->merge_range ('R1:S1', 'Points', $format);
}

sub do_head2head_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('D:I', 3);
	$worksheet->set_column ('K:L', 5);

	$worksheet->write ('A1', 'Home team', $format);
	$worksheet->write ('B1', 'Away team', $format);
	$worksheet->merge_range ('D1:I1', 'Head to Head', $format);
	$worksheet->merge_range ('K1:L1', 'Points', $format);
}

sub do_league_places_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('D:E', 5);
	$worksheet->set_column ($_, 3) for (qw (C:C F:G I:I K:K));
	$worksheet->set_column ($_, 8) for (qw (H:H J:J L:L));

	$worksheet->write ('A1', 'Home team', $format);
	$worksheet->write ('B1', 'Away team', $format);
	$worksheet->merge_range ('D1:E1','Positions', $format);
	$worksheet->write ('H1', 'Homes', $format);
	$worksheet->write ('J1', 'Aways', $format);
	$worksheet->write ('L1', 'Draws', $format);
	$worksheet->merge_range ('N1:P1', 'Percentages', $format);
}

sub do_goal_diff_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:B', 25);
	$worksheet->set_column ('E:E', 5);
	$worksheet->set_column ($_, 3) for (qw (C:D F:G I:I K:K));
	$worksheet->set_column ($_, 8) for (qw (E:E H:H J:J L:L));

	$worksheet->write ('A1', 'Home team', $format);
	$worksheet->write ('B1', 'Away team', $format);
	$worksheet->merge_range ('D1:F1', 'Goal Difference', $format);
	$worksheet->write ('H1', 'Homes', $format);
	$worksheet->write ('J1', 'Aways', $format);
	$worksheet->write ('L1', 'Draws', $format);
	$worksheet->merge_range ('N1:P1', 'Percentages', $format);
}

sub do_recent_draws_header {
	my ($worksheet, $format) = @_;

	$worksheet->set_column ('A:A', 15);
	$worksheet->set_column ('F:G', 10);
	$worksheet->set_column ($_, 3) for (qw (B:B E:E));
	$worksheet->set_column ($_, 25) for (qw (C:D I:I));

	$worksheet->write ('A1', 'Recent Draws', $format);
	$worksheet->write ('C1', 'Home team', $format);
	$worksheet->write ('D1', 'Away team', $format);
	$worksheet->write ('F1', 'Home', $format);
	$worksheet->write ('G1', 'Away', $format);
	$worksheet->write ('I1', 'League', $format);
}

1;
