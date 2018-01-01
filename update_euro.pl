#!	C:/Strawberry/perl/bin

#	update_euro.pl 26/06/17

use strict;
use warnings;

use MyJSON qw(write_json);
use Rugby::Rugby_Data_Model;
use Data::Dumper;

my $path = "C:/Mine/perl/Football/data/Euro/cleaned/";
my $json_file = $path."season.json";
my @files = ("Irish","Swedish","Norwegian","USA");

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

=pod

=head1 NAME

update_euro.pl

=head1 SYNOPSIS

perl update_euro.pl

=head1 DESCRIPTION

Create season.json file from csv files created by euro_results.pl

=head1 AUTHOR

Steve Hope 2017

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut