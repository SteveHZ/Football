#!	C:/Strawberry/perl/bin

#	form.pl 21-26/11/16, 30/06/17, 01/09/17

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Model;
use Football::Form_Model;
use Euro::Model;
use Summer::Model;
use List::MoreUtils qw(each_arrayref);

my @models = (
	Football::Model->new (),
	Euro::Model->new (),
#	Summer::Model->new (),
);
my @filenames = (
	'form.xlsx',
	'Euro/form.xlsx',
#	'Summer/form.xlsx'
);

my $iterator = each_arrayref (\@models, \@filenames);
while (my ($model, $filename) = $iterator->()) {
	my $games = $model->read_games ();
	my $leagues = $model->build_leagues ($games);

	$model->do_homes ($leagues);
	$model->do_aways ($leagues);
	$model->do_last_six ($leagues);

	my $form_model = Football::Form_Model->new (
		leagues => $leagues,
		filename => $filename,
	);
	$form_model->show ($filename);
}

=pod

=head1 NAME

form.pl

=head1 SYNOPSIS

perl form.pl

=head1 DESCRIPTION

Create form spreadsheet

=head1 AUTHOR

Steve Hope 2016 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
