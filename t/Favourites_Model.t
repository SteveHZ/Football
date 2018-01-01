#!	C:/Strawberry/perl/bin

#	Favourites_Model.t 14/09/16, 02/07/17

use strict;
use warnings;
use Test::More tests => 1;

use lib "C:/Mine/perl/Football";
use Football::Favourites_Model;

my $model = Football::Favourites_Model->new (update => 0, filename => 'uk');

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Favourites_Model', '$model');
};