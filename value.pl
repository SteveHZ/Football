#	value.pl 27-30/10/19, v1.1 add double_chance 21/02/20

use strict;
use warnings;

use List::MoreUtils qw(each_arrayref);

use Football::Value::Value_Model;
use Football::Spreadsheets::Value_View;
use MyJSON qw(read_json write_json);

my $dir = 'C:/Mine/perl/Football/data/value';
my $csv_file = 'C:/Mine/perl/Football/data/value/fixtures.csv';
my $model = Football::Value::Value_Model->new ();
my $view = Football::Spreadsheets::Value_View->new ();

$model->download_football_data ();
my $football_data = $model->get_football_data_model ($csv_file);

write_json ("$dir/data.json", $football_data);
my $mine = read_json ('C:/Mine/perl/Football/data/match odds.json');

my $odds = $model->collate_data ($mine, $football_data);
my $value = $model->calc_data ($odds);

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
