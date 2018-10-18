#!	C:/Strawberry/perl/bin

#	rugby_archive.pl 15/01/17
#	v2 22/04/17

use strict;
use warnings;

#==========================================================================
package Rugby_Archive;

use Moo;
use namespace::clean;

with 'Roles::MyJSON';

#==========================================================================
package main;

use Rugby::Rugby_Data_Model;

my $year = 2017;
my $path = 'C:/Mine/perl/Football/data/Rugby/historical/';
my $archive_path = "C:/Mine/perl/Football/data/Rugby/historical/$year/";
my $json_file = $path.$year.' season.json';

main ();

sub main {
	my $data_model = Rugby::Rugby_Data_Model->new ();
	my $archive = Rugby_Archive->new ();
	my $data = $archive->read_json ($json_file);

	mkdir $archive_path unless -d $archive_path;
	$data_model->write_csv ($data, $archive_path);

	print "\nDone.";
}
