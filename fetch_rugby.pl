#	fetch.pl 19-20/01/18, 27/02/21
#	fetch_rugby.pl 23/09/23

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Globals qw($summer_season);
use File::Fetch;


my $dir = 'C:/Mine/perl/Football/data';

my $url = "https://github.com/octonion/rugby/blob/master/super_league/csv/super-league-2023.csv";

my $ff = File::Fetch->new (uri => $url);
my $file = $ff->fetch (to => $dir) or die $ff->error;
print "\nDownloading $file...";


#unless (defined $ARGV[0] && $ARGV[0] eq '-n') {
#	my $amend = Football::Fetch_Amend->new ();
#	$amend->amend_uk ();
#	$amend->amend_euro ();
#}

=pod

=head1 NAME

Football/fetch.pl

=head1 SYNOPSIS

perl fetch.pl
perl fetch_summer.pl -n to download without amendment

=head1 DESCRIPTION

Stand-alone script to download csv files from wwww.football-data.co.uk
then download and extract Euro zip files.

Run perl fetch.pl -n to download files without amendment at the end of the season,
then run perl amend_historical.pl to archive

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
