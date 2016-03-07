
#	Football.t 28/02/16
#	using $view in this test file will clear existing spreadsheets !!!

use strict;
use warnings;
use Test::More;
use Test::Deep;
#use Data::Dumper;

use lib "C://Mine/perl/Football";
BEGIN { use_ok ("Football::Model") };
BEGIN { use_ok ("Football::View") };
BEGIN { use_ok ("Football::Team") };

my $model = Football::Model->new ();
my $view = Football::View->new ();

ok (defined $model, 'created ...');
ok ($model->isa ('Football::Model'), 'a new Football::Model class');
ok (defined $view, 'created ...');
ok ($view->isa ('Football::View'), 'a new Football::View class');

my $games = $model->read_teams ();
my ($teams, $table) = $model->build_teams ($games);

my $games_test = {
	home_team => re ('\w'),
	away_team => re ('\w'),
	home_score => re ('\d'),
	away_score => re ('\d'),
	date => re ('\d\d/\d\d/\d\d'),
};
cmp_deeply ($games, array_each ($games_test), "all games match expected format");

my $is_team_test = all (
	isa ("Football::Team"),
);
cmp_deeply ($teams, hash_each ($is_team_test), "all teams are Football::Team classes");
cmp_deeply ($table, isa ("Football::Table"),, "table is a Football::Table class");

done_testing ();



=head2
# this did pass but doesnt now, should fail on position 
for my $team (keys %$teams) {
#if ($team eq "Stoke") { print Dumper($teams->{$team});}
	my $teams_test = {
#	my $teams_test = all (
#		'$team'->{position} => re ('\D\D\D'),
#		$teams->{$team}->{position} => re ('\D\D\D'),
		$teams->{$team}->{position} => ignore (),
#		position => re ('\d'),
#		games => ignore (),
	};
#	);
#	cmp_deeply ($teams, hash_each ($teams_test), "checked all teams match expected format");
#	cmp_deeply ($teams->{$team}, $teams_test, "checked all teams match expected format");
	cmp_deeply ($teams->{$team}, hash_each ($teams_test), "checked all teams match expected format");
#	cmp_deeply (\%{$teams->{$team}}, hash_each ($teams_test), "checked all teams match expected format");
}
for my $team (keys %$teams) {
	my $team_test = {
#		$teams->{$team} => $teams->{$team}->isa ("Football::Team"),
		$team => $teams->{$team}->isa ("Football::Team"),
		games => ignore (),
		position=> ignore (),#re ('\D\D\D'),
#		"$team"->{games} => ignore (),
#		"$team"->{position}=> ignore (),#re ('\D\D\D'),
	};
#	cmp_deeply ($teams, $team_test, "team $team");
	my $test1 = hash_each ($team_test);
	cmp_deeply ($teams, $test1, "team $team");
#	cmp_deeply ($teams->{$team}, $test1, "team $team");
#	cmp_deeply ($teams->{$team}, $team_test, "team $team");

}
=cut
=head2
#	$teams is a reference to a hash of Football::Teams
for my $team (keys %$teams) {
	print "\nteam = $team";
	print "\nkey = $_" for keys (%{$teams->{$team}});
	print "\n";

	$team_test = {
#		$teams->{$team} => $teams->{$team}->isa ("Football::Team"),
		$team => $teams->{$team}->isa ("Football::Team"),
		'$team'->{games} => ignore (),
		'$team'->{position}=> ignore (),#re ('\D\D\D'),
	};

#	my $team_test = {
#ok ($model->isa ('Football::Model'), 'a new Football::Model class');
#		$team => $teams->{$team}->isa ('Football::Team'),
#		$teams->{$team} => isa ('Football::Team'),
#		$teams->{$team}->{games} => ignore (),
#		$team => isa ('Football::Team'),
#		'$team'->{games} => ignore (),
#		'$team'->{position}=> ignore (),#re ('\D\D\D'),
#	};

#	my $test1 = array_each ($team_test);
	my $test1 = hash_each ($team_test);
#	my $test1->{$team} = hash_each ($team_test);
#	cmp_deeply ($teams, $team_test, "checked all teams match expected format");
	cmp_deeply ($teams, $test1, "checked all teams match expected format");
#	cmp_deeply (\%{$teams->{$team}}, $team_test, "checked all teams match expected format");
#	cmp_deeply (\%{$teams->{$team}}, $test1, "checked all teams match expected format");
}
=cut
=head2
	my $teams_test = {
#		'$team' => ignore(),
#		'$team' => isa ('Team'),
		games => ignore (),
		position => re ('Bollox\D\D\D'),
#		{$team}->{position}=> re ('\D\D\D'),
#		'$team' => isa ('Team'),
#		'$team'->{games} => ignore (),
#		'$team'->{position}=> re ('\D\D\D'),
	};
	my $test2 = hash_each ($teams_test);
#	cmp_deeply (\%$teams, $teams_test, "checked all teams match expected format");
#	cmp_deeply (\%$teams, $tests, "checked all teams match expected format");
=cut
