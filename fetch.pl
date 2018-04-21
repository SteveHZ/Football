#	fetch.pl 19-20/01/18

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Globals qw(@csv_leagues @euro_fetch_lgs $season_years $full_season_years);

use File::Fetch;
use Archive::Extract;

my $id = 'mmz4281';
my $dir = 'C:/Mine/perl/Football/data';
my $euro_dir = 'C:/Mine/perl/Football/data/Euro';

for my $league (@csv_leagues) {
	my $url = "http://www.football-data.co.uk/$id/$season_years/$league.csv";
	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $dir) or die $ff->error;
	print "\nDownloading $file...";
}

for my $league (@euro_fetch_lgs) {
	my $url = "http://www.football-data.co.uk/$id/$season_years/$league.csv";
	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $euro_dir) or die $ff->error;
	print "\nDownloading $file...";
}

my $url = "http://www.football-data.co.uk/$id/$season_years/all-euro-data-$full_season_years.zip";
my $xlsx_file = "$dir/all-euro-data-$full_season_years.xlsx";

my $ff = File::Fetch->new (uri => $url);
my $zip_file = $ff->fetch (to => $dir) or die $ff->error;
print "\n\nDownloading $zip_file...";

print "\nUnpacking to $xlsx_file...\n";
my $ae = Archive::Extract->new (archive => $zip_file);
$ae->extract (to => $dir) or die $ae->error;
unlink $zip_file;

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
