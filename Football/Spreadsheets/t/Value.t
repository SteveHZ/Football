
use strict;
use warnings;

use Test::More tests => 1;
use List::MoreUtils qw(each_arrayref);

use Football::Value::Model;
use Football::Spreadsheets::Value_View;
use MyJSON qw(read_json write_json);

my $csv_file = 'C:/Mine/perl/Football/t/test data/value/fixtures.csv';
my $model = Football::Value::Model->new ();

my $fdata = $model->get_fdata ($csv_file);
my $mine = read_json ('C:/Mine/perl/Football/t/test data/value/match odds UK.json');

my $odds = $model->collate_data ($mine, $fdata);
my $hash = $model->calc_data ($odds);

my $view = Football::Spreadsheets::Value_View->new ();
isa_ok ($view, 'Football::Spreadsheets::Value_View', 'Value spreadsheet');
$view->view ($hash);
