#!	C:/Strawberry/perl/bin

#	csv_to_json.pl 04/09/17
#	Need to add initial 'league' column to csv file before running script

use strict;
use warnings;
use Data::Dumper;

use Football::Football_Data_Model;
use MyJSON qw(write_json);

my $in_file = "C:/Mine/perl/Football/data/Rugby/historical/2017/Middle 8s.csv";
my $out_file = "C:/Mine/perl/Football/data/Rugby/historical/2017/Middle 8s.json";

my $data_model = Football::Football_Data_Model->new ();
my $results = $data_model->update ($in_file);
print Dumper $results;

write_json ($out_file, $results);