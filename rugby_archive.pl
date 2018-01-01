#!	C:/Strawberry/perl/bin

#	rugby_archive.pl 15/01/17
#	v1.1 22/04/17, 05/06/17

use strict;
use warnings;

use File::Copy;
use Rugby::Rugby_Data_Model;
use MyJSON qw(read_json);

my $year = 2017;
my $path = "C:/Mine/perl/Football/data/Rugby/";
my $historical_path = $path."historical/";
my $archive_path = $historical_path.$year."/";

my $src_file = $path."season.json";
my $json_file = $historical_path.$year." season.json";

main ();

sub main {
	my $data_model = Rugby::Rugby_Data_Model->new ();
	
	copy $src_file, $json_file;
	my $data = read_json ($json_file);

	mkdir $archive_path unless -d $archive_path;
	$data_model->write_csv ($data, $archive_path);
	
	print "\nDone.";
}

=pod

=head1 NAME

rugby_archive.pl

=head1 SYNOPSIS

perl rugby_archive.pl

=head1 DESCRIPTION

Update rugby archives

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut