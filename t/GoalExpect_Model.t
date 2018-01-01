#!	C:/Strawberry/perl/bin

#	GoalExpect_Model.t 14/09/16

use strict;
use warnings;
use Test::More tests => 2;

use lib "C:/Mine/perl/Football";
use Football::GoalExpect_Model;

my $model = Football::GoalExpect_Model->new ();

ok (defined $model, 'created ...');
ok ($model->isa ('Football::GoalExpect_Model'), 'a new Football::GoalExpect_Model class');
