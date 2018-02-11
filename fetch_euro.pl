#	fetch_euro.pl 07/02/18

use strict;
use warnings;

use File::Fetch;
use List::MoreUtils qw(each_array);

use lib 'C:/Mine/perl/Football';
use Football::Favourites_Data_Model;
use Football::Globals qw( $euro_season );

my $test = 1;
my $euro_dir = 'C:/Mine/perl/Football/data/Euro';
my @euro_leagues = qw(SWE NOR IRL);
my @out_files = qw(Swedish Norwegian Irish);

my $data_model = Football::Favourites_Data_Model->new ();

unless ($test == 1) {
for my $league (@euro_leagues) {
	my $url = "http://www.football-data.co.uk/new/$league.csv";
	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $euro_dir) or die $ff->error;
	print "\nDownloading $file...";
}
}

my $iterator = each_array (@euro_leagues, @out_files);
while (my ($league, $file) = $iterator->()) {
	my $in_file = "$euro_dir/$league.csv";
	my $out_file = "$euro_dir/$file.csv";
	
	my $games = $data_model->read_euro ($in_file);
	my @data = grep { $_->{year} == $euro_season } @$games;

	print "\nWriting $out_file...";
	$data_model->write_csv ($out_file, \@data);
	unlink $in_file unless $test == 1;
}

=pod

=head1 NAME

Football/fetch.pl

=head1 SYNOPSIS

perl fetch.pl

=head1 DESCRIPTION

Stand-alone script to download csv files from wwww.football-data.co.uk
then download and extract Euro zip files.

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
