#!	C:/Strawberry/perl/bin

#	update_welsh.pl 13/09/17
#	update_irish 02/10/17
#	update_highland 30/10/17

use strict;
use warnings;

use MyJSON qw(write_json);
use Rugby::Rugby_Data_Model;
use Data::Dumper;

my $path = "C:/Mine/perl/Football/data/Euro/cleaned/";
my $json_file = $path."Highland_season.json";
my @files = ("Highland");

main ();

sub main {
	my $games = {};
	my $data_model = Rugby::Rugby_Data_Model->new ();
	for my $file (@files) {
		my $filename = $path.$file.".csv";
		$games->{$file." League"} = $data_model->read_archived ($filename);
	}
	print Dumper $games;
	write_json ($json_file, $games);
}