#!	C:/Strawberry/perl/bin

#	Favourites_Data_Model.t 14/09/16

use strict;
use warnings;
use Test::More tests => 1;

use lib "C:/Mine/perl/Football";
use Football::Favourites_Data_Model;

my $model = Football::Favourites_Data_Model->new ();

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Favourites_Data_Model', '$model');
};