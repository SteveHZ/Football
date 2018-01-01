#!	C:/Strawberry/perl/bin

#	Goal_Expect_Model.t 14/09/16

use strict;
use warnings;
use Test::More tests => 1;

use lib "C:/Mine/perl/Football";
use Football::Goal_Expect_Model;

my $model = Football::Goal_Expect_Model->new ();

subtest 'Constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Goal_Expect_Model', '$model');
};