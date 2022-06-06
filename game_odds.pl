# poisson_test.pl 13-15/04/22
# game_odds.pl 20-25/04/22

use strict;
use warnings;

use Football::Model;
use Football::Game_Predictions::Match_Odds;
use Football::Globals qw(@league_names);
use MyLib qw(prompt);

my $model = Football::Model->new();
my $ds = Football::Game_Predictions::Match_Odds->new ();

#my $yn;
#do {
	my $query = get_game_info ();

	my ($teams, $sorted, $stats) = $model->quick_predict2 ($query); # Quick_Model.pm role
  	my $game = $model->get_game_expect ($stats, $query); # Expect_Data.pm role
	display ($game);
#	$yn = prompt ('Another y/n ', '? ');
#} while ($yn ne 'n');

sub display {
	my $game = shift;

	print "\n$game->{home_team} v $game->{away_team} :\n";
	$ds->do_poisson ($model->get_home_goals ($game), $model->get_away_goals ($game) );
	$ds->do_poisson ($model->get_home_last_six ($game), $model->get_away_last_six ($game) );

	print "\nHome goals = ". $model->get_home_goals ($game);
	print "\nAway goals = ". $model->get_away_goals ($game);

	print "\n\nL6 Home goals = ". $model->get_home_last_six ($game);
	print "\nL6 Away goals = ". $model->get_away_last_six ($game);

	print "\n\nExpect GD = ". $model->get_expected_goal_diff ($game);
	print "\nL6 Expect GD = ". $model->get_expected_goal_diff_last_six ($game);

	print "\n\nSeason Odds :";
	$ds->show_odds ($game->{home_goals}, $game->{away_goals});
	print "\n\nLast Six Odds :";
	$ds->show_odds ($game->{home_last_six}, $game->{away_last_six});
}

sub get_game_info {
	my $league_idx = prompt ('Enter League ', ':'); 
	my $home = prompt ('Enter Home Team ', ':'); 
	my $away = prompt ('Enter Away Team ', ':'); 

	return [ {
		league_idx => $league_idx,
		league => $league_names [$league_idx],
		home_team => $home,
		away_team => $away,
	} ];
}

=begin comment
sub display {
	my $query = shift;

#	This is only working for the current fixture not a random fixture
	my $game = $model->get_game_expect ($stats, $query->{home_team});
	print "\n$game->{home_team} v $game->{away_team} :\n";

	$ds->do_poisson ($model->get_home_goals ($game), $model->get_away_goals ($game) );
	$ds->do_poisson ($model->get_home_last_six ($game), $model->get_away_last_six ($game) );

	print "\nHome goals = ". $model->get_home_goals ($game);
	print "\nAway goals = ". $model->get_away_goals ($game);

	print "\n\nL6 Home goals = ". $model->get_home_last_six ($game);
	print "\nL6 Away goals = ". $model->get_away_last_six ($game);

	print "\n\nExpect GD = ". $model->get_expected_goal_diff ($game);
	print "\nL6 Expect GD = ". $model->get_expected_goal_diff_last_six ($game);

	print "\n\nSeason Odds :";
	$ds->show_odds($game->{home_goals}, $game->{away_goals});
	print "\n\nLast Six Odds :";
	$ds->show_odds($game->{home_last_six}, $game->{away_last_six});
}
=end comment
=cut


=begin comment
#my ($teams, $sorted, $stats) = $model->quick_predict;
 
my $data = test ();
my $game = $model->get_game_expect ($data->{stats}, $data->{home_team});

#my ($teams, $sorted, $stats, $home_team) = test ();
#my $game = $model->get_game_expect ($stats, $home_team);
#my $team = prompt ('Enter Home Team ', ':'); 
#my $game = $model->get_game_expect ($stats, $team);

print "\n$game->{home_team} v $game->{away_team} :\n";

$ds->do_poisson ($model->get_home_goals ($game), $model->get_away_goals ($game) );
$ds->do_poisson ($model->get_home_last_six ($game), $model->get_away_last_six ($game) );

print "\nHome goals = ". $model->get_home_goals ($game);
print "\nAway goals = ". $model->get_away_goals ($game);

print "\n\nL6 Home goals = ". $model->get_home_last_six ($game);
print "\nL6 Away goals = ". $model->get_away_last_six ($game);

print "\n\nExpect GD = ". $model->get_expected_goal_diff ($game);
print "\nL6 Expect GD = ". $model->get_expected_goal_diff_last_six ($game);

print "\n\nSeason Odds :";
$ds->show_odds($game->{home_goals}, $game->{away_goals});
print "\n\nLast Six Odds :";
$ds->show_odds($game->{home_last_six}, $game->{away_last_six});

sub test {
	my $fixtures = [ {
#		league_idx => 2,
#		league => "League One",
#		date => "",
#		home_team => "Rotherham",
#		away_team => "Oxford",
		league_idx => 0,
		league => "Premier League",
		date => "",
		home_team => "Man City",
		away_team => "Watford",
	}];
	
	my ($teams, $sorted, $stats) = $model->quick_predict ($fixtures);
	return {
		teams => $teams,
		sorted => $sorted,
		stats => $stats,
		home_team => @$fixtures[0]->{home_team},
	};
#	return ($teams, $sorted, $stats, @$fixtures[0]->{home_team});
}

#=begin comment

use strict;
use warnings;
use Football::Game_Predictions::MyPoisson;

=begin comment

my $p = Football::Game_Predictions::MyPoisson->new ();
for my $i(0..7) {
	print "\n $i = ", $p->poisson (2.5, $i);
}
print "\n";

https://en.wikipedia.org/wiki/Poisson_distribution

María Dolores Ugarte and colleagues report that the average number of goals in a World Cup soccer match is approximately 2.5 and the Poisson model is appropriate.[15] Because the average event rate is 2.5 goals per match, λ = 2.5.
#=end comment
#=cut

use Football::Model;
use Football::Game_Predictions::Match_Odds;
use Football::Game_Predictions::MyPoisson;
use Data::Dumper;

my $ds = Football::Game_Predictions::Match_Odds->new ();
#my $stats = $ds->calc (2.05,0.12);

#$ds->do_poisson (2.05,0.12);
#$ds->show_odds (2.05,0.12);

my $model = Football::Model->new();
my ($teams, $sorted, $stats) = $model->quick_predict;
my $game = get_game_expect ($stats, "Stoke");

print "\nHome goals = ". _format ($game->{home_goals});
print "\nAway goals = ". _format ($game->{away_goals});

print "\n\nL6 Home goals = ". _format ($game->{home_last_six});
print "\nL6 Away goals = ". _format ($game->{away_last_six});

print "\n\nExpect GD = ". _format ($game->{expected_goal_diff});
print "\nL6 Expect GD = ". _format ($game->{expected_goal_diff_last_six});

#$ds->do_poisson($game->{home_goals}, $game->{away_goals});
$ds->show_odds($game->{home_goals}, $game->{away_goals});
print "\n\n";
$ds->show_odds($game->{home_last_six}, $game->{away_last_six});

sub get_game_expect {
	my ($stats, $home_team) = @_;
	for my $game ($stats->{by_match}->@*) {
		if ($game->{home_team} eq $home_team) {
			return $game;
		}
	}
	print "\nNot found !!!";
}
sub _format {
	return sprintf "%.02f", shift;
}

#my $gpm = $model->get_game_predictions_model ();
#my $data = $gpm->get_odds ($ds, $game);
#use Data::Dumper;
#print Dumper $data;
#die;

=end cooment
=cut
