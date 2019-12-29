package Football::Game_Predictions::Match_Odds;

#	Football::Match_Odds.pm 02-03/07/17

use Math::Round qw(nearest);
use List::Util qw(min);
use Football::Game_Predictions::MyPoisson;
use MyJSON qw(write_json);

use Moo;
use namespace::clean;

sub BUILD {
	my ($self, $args) = @_;

	$self->{max} = $args->{max};
	$self->{max} //= 5;

	$self->{weighted} = $args->{weighted};
	$self->{weighted} //= 0;

	$self->{stats} = ( [] );
	$self->{sheet_names} = [ qw(home_win away_win draw over_2pt5 under_2pt5 both_sides_yes both_sides_no) ];
}

sub calc {
	my ($self, $home_expect, $away_expect) = @_;
	my $p = Football::Game_Predictions::MyPoisson->new ();
	my $p_func = $p->get_calc_func ($self->{weighted});
	my %cache_p;

	for my $home_score (0..$self->{max}) {
		my $home_p = $p_func->($p, $home_expect, $home_score);
		for my $away_score (0..$self->{max}) {
			unless (exists $cache_p{$away_score}) {
				$cache_p{$away_score} = $p_func->($p, $away_expect, $away_score);
			}
			$self->{stats}[$home_score][$away_score] = $p->poisson_result ($home_p, $cache_p{$away_score});
		}
	}
	return $self->{stats};
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
	return nearest (0.01, $total);
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
	return nearest (0.01, $total);
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
	return nearest (0.01, $total);
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
	return nearest (0.01, $total);
}

sub both_sides_yes_odds {
	my $self = shift;

	my $stats = $self->both_sides_yes ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

sub both_sides_no {
	my $self = shift;
	my $total = 0;

	$total += $self->{stats}[0][0];
	for my $score (1..$self->{max}) {
		$total += $self->{stats}[$score][0];
		$total += $self->{stats}[0][$score];
	}
	return nearest (0.01, $total);
}

sub both_sides_no_odds {
	my $self = shift;

	my $stats = $self->both_sides_no ();
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
	return nearest (0.01, $total);
}

sub under_2pt5_odds {
	my $self = shift;

	my $stats = $self->under_2pt5 ();
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
	return nearest (0.01, $total);
}

sub over_2pt5_odds {
	my $self = shift;

	my $stats = $self->over_2pt5 ();
	return 0 if $stats == 0;
	return nearest (0.01, 100 / $stats);
}

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
		sort { $a->{$sorted_by} <=> $b->{$sorted_by} }
		@$games
	];
}

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
			home_win => $_->{home_win},
			away_win => $_->{away_win},
			draw => $_->{draw},
			both_sides_yes => $_->{both_sides_yes},
			both_sides_no => $_->{both_sides_no},
			over_2pt5 => $_->{over_2pt5},
			under_2pt5 => $_->{under_2pt5},
		} } @$sorted
	];
}

#sub schwartz_sort {
#	my ($self, $games) = @_;
#
#	return [
#		map	 { $_->[0] }
#		sort { $a->[1] <=> $b->[1] }
#		map	 { [
#			$_, min ( $_->{home_win},
#					  $_->{away_win} )
#		] } @$games
#	];
#}

#sub calc_weighted {
#	my ($self, $home_expect, $away_expect) = @_;
#	my $p = Football::Game_Predictions::MyPoisson->new ();
#	my %cache_p;
#
#	for my $home_score (0..$self->{max}) {
#		my $home_p = $p->poisson_weighted ($home_expect, $home_score);
#		for my $away_score (0..$self->{max}) {
#			unless (exists $cache_p{$away_score}) {
#				$cache_p{$away_score} = $p->poisson_weighted ($away_expect, $away_score);
#			}
#			$self->{stats}[$home_score][$away_score] = $p->poisson_result ($home_p, $cache_p{$away_score});
#		}
#	}
#	return $self->{stats};
#}

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
