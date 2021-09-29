#	fetch.pl 19-20/01/18, 27/02/21

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Globals qw(@csv_leagues @euro_fetch_lgs $season_years $full_season_years);
use Football::Fetch_Amend;

use File::Fetch;

#=begin comment
my $id = 'mmz4281';
my $dir = 'C:/Mine/perl/Football/data';
my $euro_dir = 'C:/Mine/perl/Football/data/Euro';

for my $league (@csv_leagues) {
	my $url = "https://www.football-data.co.uk/$id/$season_years/$league.csv";

	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $dir) or die $ff->error;
	print "\nDownloading $file...";
	sleep 1;
}

for my $league (@euro_fetch_lgs) {
	my $url = "https://www.football-data.co.uk/$id/$season_years/$league.csv";

	my $ff = File::Fetch->new (uri => $url);
	my $file = $ff->fetch (to => $euro_dir) or die $ff->error;
	print "\nDownloading $file...";
	sleep 1;
}

my $url = "https://www.football-data.co.uk/$id/$season_years/Latest_Results.xlsx";
#my $url = "https://www.football-data.co.uk/$id/$season_years/all-euro-data-$full_season_years.xlsx";
my $ff = File::Fetch->new (uri => $url);
my $euro_file = $ff->fetch (to => $dir) or die $ff->error;
print "\n\nDownloading $euro_file...";

#=end comment
#=cut

# Amend team names

unless (defined $ARGV[0] && $ARGV[0] eq '-n') {
	my $amend = Football::Fetch_Amend->new ();
	$amend->amend_uk ();
	$amend->amend_euro ();
}

=pod

=head1 NAME

Football/fetch.pl

=head1 SYNOPSIS

perl fetch.pl

=head1 DESCRIPTION

Stand-alone script to download csv files from wwww.football-data.co.uk
then download and extract Euro zip files.

Run perl fetch.pl -n to download files without amendment

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
