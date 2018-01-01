package Rugby::Rules;

#	Rugby::Rules.pm 04/12/17

use List::Util qw(sum);
use Math::Round qw(round);

use lib 'C:/Mine/perl/Football';
use parent 'Football::Rules';

use Moo;
use namespace::clean;

after 'BUILD' => sub {
	my $self = shift;

	$self->{min_points} = 7;
	$self->{max_goal_diffs} = 15;
	$self->{min_goal_diffs} = 10;
#	$self->{min_gd_percent} = 60;
#	$self->{min_odds} = 15;
};

sub home_away_rule {
	my ($self, $game) = @_;
	return "H $game->{home_away_goal_diff}"
		if $game->{home_away_goal_diff} >= $self->{max_goal_diffs}
		and $game->{home_goal_diff} >= $self->{min_goal_diffs};
		
	return "A ".sprintf "%0.2f", abs $game->{home_away_goal_diff} # abs returns integer only if argument ends with .00
		if abs $game->{home_away_goal_diff} >= $self->{max_goal_diffs}
		and $game->{away_goal_diff} >= $self->{min_goal_diffs};
	return "";
}

sub last_six_rule {
	my ($self, $game) = @_;

	return "H $game->{last_six_goal_diff}"
		if $game->{last_six_goal_diff} >= $self->{max_goal_diffs}
		and $game->{home_last_six_goal_diff} >= $self->{min_goal_diffs};

	return "A ".sprintf "%0.2f", abs $game->{last_six_goal_diff}
		if abs $game->{last_six_goal_diff} >= $self->{max_goal_diffs}
		and $game->{away_last_six_goal_diff} >= $self->{min_goal_diffs};
	return "";
}

=head1

sub points_rule {
	my ($self, $home, $away) = @_;

	return "$home.$away"
		if ($home > $self->{min_points} && ($home > $away * 2))
		or ($away > $self->{min_points} && ($away > $home * 2));
	return "";
}

sub goal_diffs_rule {
	my ($self, $results) = @_;

	my $total_games = sum @$results;
	return "***" if $total_games == 0; # unrecognised (recent) goal diff
	my $home = round ((@$results[0] / $total_games) * 100); # home win percentage
	my $away = round ((@$results[1] / $total_games) * 100); # away win precentage

	return "H $home" if $home >= $self->{min_goal_diff};
	return "A $away" if $away >= $self->{min_goal_diff};
	return "";
}

sub match_odds_rule {
	my ($self, $game) = @_;
	
	return "H $game->{away_win}" if $game->{away_win} >= $self->{min_odds};
	return "A $game->{home_win}" if $game->{home_win} >= $self->{min_odds};
	return "";
}

=cut

1;
