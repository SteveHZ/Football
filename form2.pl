#!	C:/Strawberry/perl/bin

#	form.pl 21-26/11/16

use strict;
use warnings;

use Football::Model;
use Football::Form_Model2;

main ();

sub main {
	my $model = Football::Model->new ();
	my $update = 0;
	
	my $games = $model->read_games ($update);
	my $leagues = $model->build_leagues ($games);

	$model->homes ($leagues);
	$model->aways ($leagues);
	$model->last_six ($leagues);

	my $form_model = Football::Form_Model2->new (leagues => $leagues);
	$form_model->show ();
}
