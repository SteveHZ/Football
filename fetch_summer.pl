#	fetch_euro.pl 07/02/18
#	fetch_summer.pl 12/03/18 v2 02/08/20

use strict;
use warnings;

use File::Fetch;
use List::MoreUtils qw(each_arrayref);

use lib 'C:/Mine/perl/Football';
use Summer::Summer_Data_Model;
use Football::Globals qw( $summer_season @summer_fetch_leagues @summer_csv_leagues);

my $data_model = Summer::Summer_Data_Model->new ();
my $summer_dir = 'C:/Mine/perl/Football/data/Summer';
my $summer_download_dir = 'C:/Mine/perl/Football/data/Summer/download';
my $fetch_leagues = \@summer_fetch_leagues;
my $csv_leagues = \@summer_csv_leagues;

for my $league (@$fetch_leagues) {
	my $url = "https://www.football-data.co.uk/new/$league.csv";
	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $summer_download_dir) or die $ff->error;
	print "\nDownloading $file...";
	sleep 1;
}
print "\n";

# As the football-data summer files go back to 2012, save the full file in a seperate directory,
# then grep the full file for the current season and save to the correct directory, using the same name.
# Saving the full file in the same directory caused problems when it came to delete the full file using the same names.

my $iterator = each_arrayref ($fetch_leagues, $csv_leagues);
while (my ($league, $file) = $iterator->()) {
	my $in_file = "$summer_download_dir/$league.csv";
	my $out_file = "$summer_dir/$file.csv";

	my $games = $data_model->read_data ($in_file);
	my @data = grep { $_->{year} =~ $summer_season } @$games;

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
