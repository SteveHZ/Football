#   Football/Spreadsheets/t/Extended.t 16/04/19

use strict;
use warnings;

use Test::More tests => 1;
use Football::Model;
use Football::Spreadsheets::Extended;

my $model = Football::Model->new ();
my $data = $model->quick_build ();

my $view = Football::Spreadsheets::Extended->new ();
isa_ok ($view, 'Football::Spreadsheets::Extended', 'Extended spreadsheet');

print "\nWriting Extended spreadsheet...";
$view->do_extended ( $data->{by_league} );
