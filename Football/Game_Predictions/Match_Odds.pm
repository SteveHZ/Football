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
#has 'weighted' => (is => 'ro', default => 0);

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
	state $p = Football::Game_Predictions::MyPoisson->new ();
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
			printf "%6.3f", @$stats [$home]->[$away];
		}
		print "\n";
	}
}

sub show_odds {
	my ($self, $home_expect, $away_expect) = @_;
	$self->calc ($home_expect, $away_expect);
	
	printf "\nHome Win       : %5.2f", $self->home_win_odds ();
	printf "\nDraw           : %5.2f", $self->draw_odds ();
	printf "\nAway Win       : %5.2f", $self->away_win_odds ();
	printf "\nBoth Sides Yes : %5.2f", $self->both_sides_yes_odds ();
	printf "\nBoth Sides No  : %5.2f", $self->both_sides_no_odds ();
	printf "\nOver 2.5       : %5.2f", $self->over_2pt5_odds ();
	printf "\nUnder 2.5      : %5.2f", $self->under_2pt5_odds ();
	printf "\nHome Double    : %5.2f", $self->home_double_odds ();
	printf "\nAway Double    : %5.2f", $self->away_double_odds ();
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
#	my $select = ($sorted_by =~ /.*_2pt5$/) ? 'last_six' : 'season';
	return [
		sort {
			$a->{odds}->{season}->{$sorted_by}
			<=> $b->{odds}->{season}->{$sorted_by}

#			$a->{odds}->{$select}->{$sorted_by}
#			<=> $b->{odds}->{$select}->{$sorted_by}
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
	my $total = 0;

	$total += $self->{stats}[0][0];
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
			over_2pt5 => $_->{odds}->{last_six}->{over_2pt5},
			under_2pt5 => $_->{odds}->{last_six}->{under_2pt5},
			home_double => $_->{odds}->{season}->{home_double},
			away_double => $_->{odds}->{season}->{away_double},
		} } @$sorted
	];
}

=head

#	use Football::Game_Predictions::MyPoisson ( pure perl version )
#	This needs changing so that calcs and cache are in MyPoisson::calc_game which should
#	then call MyPoisson::calc
sub calc {
	my ($self, $home_expect, $away_expect) = @_;
	state $p = Football::Game_Predictions::MyPoisson->new ();
	my %cache_p;

	for my $home_score (0..$self->{max}) {
		my $home_p = $p->poisson ($home_expect, $home_score);
		for my $away_score (0..$self->{max}) {
			unless (exists $cache_p{$away_score}) {
				$cache_p{$away_score} = $p->poisson ($away_expect, $away_score);
			}
			$self->{stats}[$home_score][$away_score] = $p->poisson_result ($home_p, $cache_p{$away_score});
		}
	}
	return $self->{stats};
}

#use Football::Game_Predictions::Poisson; # uses Math::CDF::ppois
sub calc_odds {
	my ($self, $home_expect, $away_expect) = @_;
	use Football::Game_Predictions::Poisson ( uses Math::CDF library C routines)
	my $p = Football::Game_Predictions::Poisson->new (weighted => $self->{weighted}, max => $self->{max});
	$self->{stats} = $p->calc_poisson ($home_expect, $away_expect);

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

use List::Util qw(min);
sub schwartz_sort {
	my ($self, $games) = @_;

	return [
		map	 { $_->[0] }
		sort { $a->[1] <=> $b->[1] }
		map	 { [
			$_, min ( $_->{home_win},
					  $_->{away_win} )
		] } @$games
	];
}

#	use Football::Game_Predictions::MyPoisson ( pure perl version )
sub calc {
	my ($self, $home_expect, $away_expect) = @_;
	state $p_func = $p->get_calc_func ($self->{weighted});
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

=cut

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
