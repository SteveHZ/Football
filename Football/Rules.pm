package Football::Rules;

#	Football::Rules.pm 02-03/12/17

use List::Util qw(sum);
use Math::Round qw(round);

use Moo;
use namespace::clean;

sub BUILD {
	my $self = shift;

	$self->{min_points} = 12;
	$self->{min_gd_percent} = 60;
	$self->{min_odds} = 15;
	$self->{max_goal_diff} = 1.5;
	$self->{min_goal_diff} = 1;
}

sub points_rule {
	my ($self, $home, $away) = @_;

#	return sprintf ("%s.%s", $home, $away)
	return "$home.$away"
		if ($home > $self->{min_points} && ($home > $away * 2))
		or ($away > $self->{min_points} && ($away > $home * 2));
	return "";
}

sub goal_diffs_rule {
	my ($self, $results) = @_;

	my $total_games = sum @$results;
	return 0 if $total_games == 0; # unrecognised goal diff

	my $home = round ((@$results[0] / $total_games) * 100); # home win percentage
	my $away = round ((@$results[1] / $total_games) * 100); # away win precentage

	return "H $home" if $home >= $self->{min_gd_percent};
	return "A $away" if $away >= $self->{min_gd_percent};
	return "";
}

sub match_odds_rule {
	my ($self, $game) = @_;

	return "H ".sprintf "%0.2f", $game->{away_win} if $game->{away_win} >= $self->{min_odds};
	return "A ".sprintf "%0.2f", $game->{home_win} if $game->{home_win} >= $self->{min_odds};
	return "";
}

sub home_away_rule {
	my ($self, $game) = @_;

	return "H $game->{home_away_goal_diff}"
		if $game->{home_away_goal_diff} >= $self->{max_goal_diff}
		and $game->{home_goal_diff} >= $self->{min_goal_diff};
		
	return "A ".sprintf "%0.2f", abs $game->{home_away_goal_diff} # abs returns integer only if argument ends with .00
		if abs $game->{home_away_goal_diff} >= $self->{max_goal_diff}
		and $game->{away_goal_diff} >= $self->{min_goal_diff};
	return "";
}

sub last_six_rule {
	my ($self, $game) = @_;

	return "H $game->{last_six_goal_diff}"
		if $game->{last_six_goal_diff} >= $self->{max_goal_diff}
		and $game->{home_last_six_goal_diff} >= $self->{min_goal_diff};

	return "A ".sprintf "%0.2f", abs $game->{last_six_goal_diff}
		if abs $game->{last_six_goal_diff} >= $self->{max_goal_diff}
		and $game->{away_last_six_goal_diff} >= $self->{min_goal_diff};
	return "";
}

sub ou_home_away_rule {
	my ($self, $game) = @_;
	return sprintf "%0.2f", $game->{home_away}
		if $game->{home_away} >= 0.75;
	return "";
}

sub ou_last_six_rule {
	my ($self, $game) = @_;
	return sprintf "%0.2f", $game->{last_six}
		if $game->{last_six} >= 0.75;
	return "";
}

sub over_odds_rule {
	my ($self, $game) = @_;
	return sprintf "+ %0.2f", $game->{over_2pt5}
		if $game->{over_2pt5} < 2.00;
	return "";
}

sub under_odds_rule {
	my ($self, $game) = @_;
	return sprintf "- %0.2f", $game->{under_2pt5}
		if $game->{under_2pt5} >= 4.00;
	return "";
}

1;
