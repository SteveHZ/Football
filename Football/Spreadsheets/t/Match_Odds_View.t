#   Football/Spreadsheets/t/Match_Odds_View.t 20/02/20

use strict;
use warnings;

use Test::More tests => 1;
use Football::Model;
use Football::Spreadsheets::Match_Odds_View;

my $model = Football::Model->new ();
my ($teams, $sorted) = $model->quick_predict ();

my $view = Football::Spreadsheets::Match_Odds_View->new ();
isa_ok ($view, 'Football::Spreadsheets::Match_Odds_View', 'Match Odds View spreadsheet');

print "\nWriting Match Odds View spreadsheet...";
$view->view ($sorted->{match_odds});
print "\n\nMatch Odds View spreadsheet completed.";
