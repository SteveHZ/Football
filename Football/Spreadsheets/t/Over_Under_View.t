#   Football/Spreadsheets/t/Over_Under_View.t 16/04/19

use strict;
use warnings;

use Test::More tests => 1;
use Football::Model;
use Football::Spreadsheets::Over_Under_View;

my $model = Football::Model->new ();
my ($teams, $sorted) = $model->quick_predict ();

my $view = Football::Spreadsheets::Over_Under_View->new ();
isa_ok ($view, 'Football::Spreadsheets::Over_Under_View', 'Over Under View spreadsheet');

print "\nWriting Over_Under View spreadsheet...";
$view->view ($sorted->{over_under});
