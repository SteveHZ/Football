#!	C:/Strawberry/perl/bin

#	predict.pl 31/01/16 - 14/03/16
# 	v2.0 23/03/16 - 19/04/16 v2.05 10/09/16
# 	v2.08 02/04/17 v2.10 08/05/17 v2.12 27/06/17
#	v2.13 26/07/17 v2.14 07/10/17 v2.15 29/11/17
#	v2.20 30/11/17 - 02/12/17

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib 'C:/Mine/perl/Football';
use Football::Model;
use Football::View;
use Football::Globals qw( $season );

use Rugby::Model;
use Rugby::View;

use Euro::Model;
use Euro::View;

main ();

sub main {
	my ($sport, $update, $update_favs) = get_cmdline ();

	my $model = ($sport."::Model")->new ();
	my $view = ($sport."::View")->new ();

	my $games = $model->read_games (update => $update);
	my $leagues = $model->build_leagues ($games);

	$view->do_teams ($leagues);
	$view->do_table ($leagues);

	$view->do_home_table ( $model->do_home_table ($games) );
	$view->do_away_table ( $model->do_away_table ($games) );

	$view->homes (
		my $homes = $model->homes ($leagues)
	);
	$view->aways (
		my $aways = $model->aways ($leagues)
	);

	$view->full_homes ( $homes );
	$view->full_aways ( $aways );
	$view->last_six ( 
		my $last_six = $model->last_six ($leagues)
	);

	$view->fixtures (
		my $fixture_list = $model->get_fixtures ()
	);
	$view->do_fixtures (
		my $fixtures = $model->do_fixtures ($fixture_list, $homes, $aways, $last_six)
	);

	$view->do_recent_goal_difference ( $model->do_recent_goal_difference ($fixtures, $leagues) );
	$view->do_goal_difference ( $model->do_goal_difference ($fixtures, $leagues) );
	$view->do_league_places ( $model->do_league_places ($fixtures, $leagues) );
	$view->do_head2head ( $model->do_head2head ($fixtures) );
	
	$view->do_recent_draws ( $model->do_recent_draws ($fixtures) );
	$view->do_favourites ( $model->do_favourites ($season, $update_favs) );

	my ($teams, $sorted) = $model->do_predict_models ($leagues, $fixture_list, $fixtures, $sport);

	$view->do_goal_expect ($leagues, $teams, $sorted, $fixture_list);
	$view->do_match_odds ($sorted);
	$view->do_over_under ($sorted);
}

sub get_cmdline {
	my ($rugby, $euro, $update, $favs, $update_favs);
	
	Getopt::Long::Configure ("bundling");
	GetOptions (
		'rugby|r' => \$rugby,
		'euro|e' => \$euro,
		'update|u' => \$update,
		'update_favs|f' => \$favs,
	) or die "Usage perl predict.pl -u -uf -r -ru -e -eu";

	my $sport_name = "Football";
	$sport_name = "Rugby" if $rugby;
	$sport_name = "Euro" if $euro;
	$update_favs = ($update && (! $favs)) ? 1 : 0; # do NOT update favourites if set

	return ($sport_name, $update, $update_favs);
}

=pod

=head1 NAME

predict.pl

=head1 SYNOPSIS

 cd football
 perl predict.pl 
 perl predict.pl -u
 perl predict.pl -e
 perl predict.pl -eu
 update_rugby

=head1 DESCRIPTION

Football predictions

=head1 AUTHOR

Steve Hope 2016 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut