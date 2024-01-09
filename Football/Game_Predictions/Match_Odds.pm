package Football::Game_Predictions::Match_Odds;

#	Football::Match_Odds.pm 02-03/07/17

use v5.10; # state
use Math::Round qw(nearest);
use Football::Game_Predictions::MyPoisson;
use MyJSON qw(write_json);

use Moo;
use namespace::clean;

has 'max' => (is => 'ro', default => 5);
has 'stats' => (is => 'rw');

sub BUILD {
	my ($self, $args) = @_;

	$self->{stats} = [];
	$self->{sheet_names} = [ qw(home_win away_win draw over_2pt5 under_2pt5 home_double away_double both_sides_yes both_sides_no) ];
}

sub calc_odds {
	my ($self, $home_expect, $away_expect) = @_;
	$self->calc ($home_expect, $away_expect);

	return {
		home_win => $self->home_win_odds (),
		away_win => $self->away_win_odds (),
		draw => $self->draw_odds (),
		both_sides_yes => $self->both_sides_yes_odds (),
		both_sides_no => $self->both_sides_no_odds (),
		under_2pt5 => $self->under_2pt5_odds (),
		over_2pt5 => $self->over_2pt5_odds (),
		home_double => $self->home_double_odds (),
		away_double => $self->away_double_odds (),
	};
}

sub calc {
	my ($self, $home_expect, $away_expect) = @_;
	state $p = Football::Game_Predictions::MyPoisson->new ( max => $self->{max} );
	$self->{stats} = $p->calc_game ($home_expect, $away_expect);
	return $self->{stats};
}

#  API for testing

sub do_poisson {
	my ($self, $home_expect, $away_expect) = @_;
	my $stats = $self->calc ($home_expect, $away_expect);
	$self->show_poisson ($stats);
}

sub show_poisson {
	my ($self, $stats) = @_;
	print "\n";
	for my $home (0...$self->{max}) {
		for my $away (0...$self->{max}) {
			printf "%7.3f", @$stats [$home]->[$away];
		}
		print "\n";
	}
}

sub show_odds {
	my ($self, $home_expect, $away_expect) = @_;
	my $ds = $self->calc_odds ($home_expect, $away_expect);
	
	printf "\nHome Win       : %5.2f = %5.2f%%", $ds->{home_win}, 100 / $ds->{home_win};
	printf "\nDraw           : %5.2f = %5.2f%%", $ds->{draw}, 100 / $ds->{draw};
	printf "\nAway Win       : %5.2f = %5.2f%%", $ds->{away_win}, 100 / $ds->{away_win};
	printf "\nBoth Sides Yes : %5.2f = %5.2f%%", $ds->{both_sides_yes}, 100 / $ds->{both_sides_yes};
	printf "\nBoth Sides No  : %5.2f = %5.2f%%", $ds->{both_sides_no}, 100 / $ds->{both_sides_no};
	printf "\nOver 2.5       : %5.2f = %5.2f%%", $ds->{over_2pt5}, 100 / $ds->{over_2pt5};
	printf "\nUnder 2.5      : %5.2f = %5.2f%%", $ds->{under_2pt5}, 100 / $ds->{under_2pt5};
	printf "\nHome Double    : %5.2f = %5.2f%%", $ds->{home_double}, 100 / $ds->{home_double};
	printf "\nAway Double    : %5.2f = %5.2f%%", $ds->{away_double}, 100 / $ds->{away_double};
}
# end API for testing

sub sort_sheets {
	my ($self, $fixtures) = @_;
	my $sorted = {};
	for my $sheet ($self->{sheet_names}->@*) {
		$sorted->{$sheet} = $self->sort_by_sheet_name ($fixtures, $sheet);
	}
	return $sorted;
}

sub sort_by_sheet_name {
	my ($self, $games, $sorted_by) = @_;
	return [
		sort {
			$b->{odds}->{season}->{$sorted_by}
			<=> $a->{odds}->{season}->{$sorted_by}
		} @$games
	];
}

sub print_all {
	my $self = shift;
	for my $home_score (0..$self->{max}) {
		for my $away_score (0..$self->{max}) {
			print "\n$home_score - $away_score = ".
				$self->{stats}[$home_score][$away_score];
		}
	}
}

sub home_win {
	my $self = shift;
	my $total = 0;

	for my $home_score (1..$self->{max}) {
		for my $away_score (0..$home_score - 1) {
			$total += $self->{stats}[$home_score][$away_score];
		}
	}
	return $total;
}

sub home_win_odds {
	my $self = shift;

	my $stats = $self->home_win ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub away_win {
	my $self = shift;
	my $total = 0;

	for my $away_score (1..$self->{max}) {
		for my $home_score (0..$away_score - 1) {
			$total += $self->{stats}[$home_score][$away_score];
		}
	}
	return $total;
}

sub away_win_odds {
	my $self = shift;
	my $stats = $self->away_win ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub draw {
	my $self = shift;
	my $total = 0;

	for my $score (0..$self->{max}) {
		$total += $self->{stats}[$score][$score];
	}
	return $total;
}

sub draw_odds {
    my $self = shift;

    my $stats = $self->draw ();
    return 0 if $stats == 0;
    return nearest (0.01, 100 / $stats);
}

sub both_sides_yes {
	my $self = shift;
	my $total = 0;

	for my $home_score (1..$self->{max}) {
		for my $away_score (1..$self->{max}) {
			$total += $self->{stats}[$home_score][$away_score];
		}
	}
	return $total;
}

sub both_sides_yes_odds {
	my $self = shift;

	my $stats = $self->both_sides_yes ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub both_sides_no {
	my $self = shift;
	my $total = $self->{stats}[0][0];

	for my $score (1..$self->{max}) {
		$total += $self->{stats}[$score][0];
		$total += $self->{stats}[0][$score];
	}
	return $total;
}

sub both_sides_no_odds {
	my $self = shift;

	my $stats = $self->both_sides_no ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub over_2pt5 {
	my $self = shift;
	my $total = 0;

	for my $home_score (0..$self->{max}) {
		for my $away_score (0..$self->{max}) {
			if ($home_score + $away_score > 2) {
				$total += $self->{stats}[$home_score][$away_score];
			}
		}
	}
	return $total;
}

sub over_2pt5_odds {
	my $self = shift;

	my $stats = $self->over_2pt5 ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub under_2pt5 {
	my $self = shift;
	my $total = 0;

	for my $home_score (0..2) {
		for my $away_score (0..2) {
			if (($home_score + $away_score) < 3) {
				$total += $self->{stats}[$home_score][$away_score];
			}
		}
	}
	return $total;
}

sub under_2pt5_odds {
	my $self = shift;

	my $stats = $self->under_2pt5 ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub home_double_odds {
	my $self = shift;

	my $stats = $self->home_win () + $self->draw ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub away_double_odds {
	my $self = shift;

	my $stats = $self->away_win () + $self->draw ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

#	used to write out data to then read from value.pl
sub save_match_odds {
	my ($self, $sorted, $path) = @_;
	my $filename = "$path/match odds.json";
	write_json ($filename, $self->get_match_odds ($sorted));
}

sub get_match_odds {
	my ($self, $sorted) = @_;
	return [
		map { {
			league => $_->{league},
			home_team => $_->{home_team},
			away_team => $_->{away_team},
			home_win => $_->{odds}->{season}->{home_win},
			away_win => $_->{odds}->{season}->{away_win},
			draw => $_->{odds}->{season}->{draw},
			both_sides_yes => $_->{odds}->{season}->{both_sides_yes},
			both_sides_no => $_->{odds}->{season}->{both_sides_no},
			over_2pt5 => $_->{odds}->{season}->{over_2pt5},
			under_2pt5 => $_->{odds}->{season}->{under_2pt5},
			home_double => $_->{odds}->{season}->{home_double},
			away_double => $_->{odds}->{season}->{away_double},
		} } @$sorted
	];
}

=pod

=head1 NAME

Match_Odds.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
