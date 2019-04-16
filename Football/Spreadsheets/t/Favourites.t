#   Football/Spreadsheets/t/Favourites.t 16/04/19

use strict;
use warnings;

use Test::More tests => 1;
use Football::Model;
use Football::Spreadsheets::Favourites;
use Football::Globals qw( $season );

my $model = Football::Model->new ();
my $data = $model->quick_build ();

my $view = Football::Spreadsheets::Favourites->new ( filename => 'current');
isa_ok ($view, 'Football::Spreadsheets::Favourites', 'Favourites spreadsheet');

print "\nWriting Favourites spreadsheet...";
$view->do_favourites ( $model->do_favourites ($season, 0) ); # DO NOT UPDATE
