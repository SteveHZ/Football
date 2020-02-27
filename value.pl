#	value.pl 27-30/10/19, v1.1 add double_chance 21/02/20

BEGIN {
$ENV{PERL_KEYWORD_PRODUCTION} = 1;
}

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref);

use Football::Value::Model;
use Football::Spreadsheets::Value_View;
use MyKeyword qw(PRODUCTION);
use MyJSON qw(read_json write_json);

my $dir = 'C:/Mine/perl/Football/data/value';
my $csv_file = 'C:/Mine/perl/Football/data/value/fixtures.csv';
my $model = Football::Value::Model->new ();
my $view = Football::Spreadsheets::Value_View->new ();

PRODUCTION {
    $model->download_fdata ();
}

my $fdata = $model->get_fdata ($csv_file);
write_json ("$dir/data.json", $fdata);
my $mine = read_json ('C:/Mine/perl/Football/data/match odds.json');

my $odds = $model->collate_data ($mine, $fdata);
my $value = $model->calc_data ($odds);

print "\nWriting C:/Mine/perl/Football/reports/value.xlsx...";
$view->view ($value);

=pod

=head1 NAME

Football/value.pl

=head1 SYNOPSIS

perl value.pl

=head1 DESCRIPTION

Stand-alone script to download csv files from wwww.football-data.co.uk
and compare to calculated odds for value bets

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
