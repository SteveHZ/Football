#	fetch_euro.pl 07/02/18
#	fetch_summer.pl 12/03/18

use strict;
use warnings;

use File::Fetch;
use List::MoreUtils qw(each_array);

use lib 'C:/Mine/perl/Football';
use Summer::Summer_Data_Model;
use Football::Globals qw( $euro_season );

my $summer_dir = 'C:/Mine/perl/Football/data/Summer';
my @leagues = qw(SWE NOR IRL USA);
my @out_files = qw(Swedish Norwegian Irish American);

my $data_model = Summer::Summer_Data_Model->new ();

for my $league (@leagues) {
	my $url = "http://www.football-data.co.uk/new/$league.csv";
	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $summer_dir) or die $ff->error;
	print "\nDownloading $file...";
}
print "\n";

my $iterator = each_array (@leagues, @out_files);
while (my ($league, $file) = $iterator->()) {
	my $in_file = "$summer_dir/$league.csv";
	my $out_file = "$summer_dir/$file.csv";
	
	my $games = $data_model->read_data ($in_file);
	my @data = grep { $_->{year} == $euro_season } @$games;

	print "\nWriting $out_file...";
	$data_model->write_csv ($out_file, \@data);
	unlink $in_file;
}

=pod

=head1 NAME

Football/fetch_summer.pl

=head1 SYNOPSIS

perl fetch_summer.pl

=head1 DESCRIPTION

Stand-alone script to download csv files for summer leagues from wwww.football-data.co.uk

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut