#!	C:/Strawberry/perl/bin

#	form.pl 21-26/11/16
#	form3.pl 30/06/17

use strict;
use warnings;
use List::MoreUtils qw(each_array);

use Football::Model;
use Football::Form_Model;
use Euro::Model;

main ();

sub main {
	my @models = (
		Football::Model->new (),
		Euro::Model->new (),
	);
	my @filenames = ("form.xlsx", "euro_form.xlsx");
	my $update = 0;

	my $iterator = each_array (@models, @filenames);
	while (my ($model, $filename) = $iterator->()) {
		my $games = $model->read_games ($update);
		my $leagues = $model->build_leagues ($games);

		$model->homes ($leagues);
		$model->aways ($leagues);
		$model->last_six ($leagues);

		my $form_model = Football::Form_Model->new (leagues => $leagues);
		$form_model->show ($filename);
	}	
}
