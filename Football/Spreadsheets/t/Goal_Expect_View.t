#   Football/Spreadsheets/t/Goal_Expect_View.t 16/04/19

use strict;
use warnings;

use Test::More tests => 1;
use Football::Model;
use Football::Spreadsheets::Goal_Expect_View;

my $model = Football::Model->new ();
my ($teams, $sorted) = $model->quick_predict ();

my $view = Football::Spreadsheets::Goal_Expect_View->new ();
isa_ok ($view, 'Football::Spreadsheets::Goal_Expect_View', 'Goal Expect View spreadsheet');

print "\nWriting Goal Expect View spreadsheet...";
$view->view ($model->leagues, $teams, $sorted->{expect});
