#!	C:/Strawberry/perl/bin

#	predict.pl 31/01/16 - 14/03/16
#	v3.0 12/03/18 v3.02 22/08/18 v3.03 22/09/18
#	v3.10 06/05/19

BEGIN {
#$ENV{PERL_KEYWORD_DEVELOPMENT} = 1;
$ENV{PERL_KEYWORD_ZEROGAMES} = 1;
}

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib 'C:/Mine/perl/Football';
use Football::Globals qw( $season );
use Football::Model;
use Football::View;
use Euro::Model;
use Euro::View;
use Summer::Model;
use Summer::View;
use Rugby::Model;
use Rugby::View;

use Football::Favourites::Controller;
use Football::Game_Predictions::Controller;

my $options = get_cmdline ();
my ($model, $view) = get_model_and_view ($options);

my $games = $model->read_games ($options->{update});
my $leagues = $model->build_leagues ($games);

$view->do_teams ($leagues);
$view->do_table ($leagues);
$view->do_home_table ( $leagues );
$view->do_away_table ( $leagues );

$view->homes (
	my $homes = $model->do_homes ($leagues)
);
$view->aways (
	my $aways = $model->do_aways ($leagues)
);

$view->full_homes ( $homes );
$view->full_aways ( $aways );
$view->last_six (
	my $last_six = $model->do_last_six ($leagues)
);

$view->fixture_list (
	my $fixtures = $model->get_fixtures ()
);

my $data = $model->do_fixtures ($fixtures);
$view->fixtures ( $data->{by_league} );

$view->do_recent_goal_difference ( $model->do_recent_goal_difference ($data->{by_league}, $leagues) );
$view->do_goal_difference ( $model->do_goal_difference ($data->{by_league}, $leagues) );
$view->do_league_places ( $model->do_league_places ($data->{by_league}, $leagues) );
$view->do_head2head ( $model->do_head2head ($data->{by_league} ) );
$view->do_recent_draws ( $model->do_recent_draws ($data->{by_league} ) );

if ($model->model_name eq 'UK') {
	my $favourites = Football::Favourites::Controller->new (
		season => $season,
		update => $options->{update},
		filename => 'uk'
	);
	$favourites->do_favourites ();
}

my $predict = Football::Game_Predictions::Controller->new (
	fixtures => $data->{by_match},
	leagues => $leagues,
	view_name => $model->model_name
);
$predict->do_predictions ();

sub get_cmdline {
	my ($uk, $euro, $summer, $update, $favs, $rugby) = (0,0,0,0,0,0);

	Getopt::Long::Configure ("bundling");
	GetOptions (
		'euro|e' => \$euro,
		'summer|s' => \$summer,
		'update|u' => \$update,
		'update_favs|f' => \$favs,
		'rugby|r' => \$rugby,
	) or die "Usage perl predict.pl -u -uf -r -ru -e -eu -s -su";

	my $update_favs = ($update && (! $favs)) ? 1 : 0; # do NOT update favourites if set
	$uk = 1 unless ($euro or $summer or $rugby);

	return {
		uk => $uk,
		euro => $euro,
		summer => $summer,
		update => $update,
		update_favs => $update_favs,
		rugby => $rugby,
	};
}

sub get_model_and_view {
	my $options = shift;

	return (Football::Model->new (), Football::View->new ()) if $options->{uk};
	return (Euro::Model->new (), Euro::View->new ()) if $options->{euro};
	return (Summer::Model->new (), Summer::View->new ()) if $options->{summer};
	return (Rugby::Model->new (), Rugby::View->new ()) if $options->{rugby};
	die "Unknown error in get_model_and_view";
}

=pod

=head1 NAME

predict.pl

=head1 SYNOPSIS

 cd football
 perl predict.pl
 perl predict.pl -u
 perl predict.pl -e OR -eu
 perl predict.pl -s OR -su
 Also add -f to NOT update the favourites spreadsheets
 update_rugby

=head1 DESCRIPTION

Football predictions

=head1 AUTHOR

Steve Hope 2016 2017 2018

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# 	v2.0 23/03/16 - 19/04/16 v2.05 10/09/16
# 	v2.08 02/04/17 v2.10 08/05/17 v2.12 27/06/17
#	v2.13 26/07/17 v2.14 07/10/17 v2.15 29/11/17
#	v2.20 30/11/17 - 02/12/17
