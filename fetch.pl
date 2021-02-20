#	fetch.pl 19-20/01/18

use strict;
use warnings;

use lib 'C:/Mine/perl/Football';
use Football::Globals qw(@csv_leagues @euro_fetch_lgs $season_years $full_season_years);
use MyLib qw(read_file write_file);

use File::Fetch;
use File::Copy qw(copy);

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

# Amend team names

my %replace = (
	'E2' => [ sub { $_[0] =~ s/M.*Dons/MK Dons/g }, ],
	'EC' => [ sub { $_[0] =~ s/K.*nn/Kings Lynn/g }, ],
);

while (my ($league, $teams_rx) = each %replace) {
	my $file = "C:/Mine/perl/Football/data/$league.csv";
	my $temp_file = "C:/Mine/perl/Football/data/$league-temp.csv";

  	print "\nRewriting $file...";
  	copy $file, $temp_file;
  	my $lines = read_file ($temp_file);
	for my $replace_rx (@$teams_rx) {
		$replace_rx->($_) for @$lines;
	}

   	write_file ($file, $lines);
   	unlink $temp_file;
}

=begin comment
# Workaround for Kings Lynn
# to remove Unicode backward apostrophe from dowloaded files
# as lisp can't read that character in (update-csv-files)
# Also amend Milton Keynes Dons to MK Dons

use List::MoreUtils qw(each_array);
my @files = qw(E2 EC);
my @replace_rx = (
	sub { $_[0] =~ s/M.*Dons/MK Dons/g },
	sub { $_[0] =~ s/K.*nn/Kings Lynn/g },
);

my $iterator = each_array (@files, @replace_rx);
while (my ($filename, $replace) = $iterator->()) {
	my $file = "C:/Mine/perl/Football/data/$filename.csv";
	my $temp_file = "C:/Mine/perl/Football/data/$filename-temp.csv";

  	print "\nRewriting $file...";
  	copy $file, $temp_file;
  	my $lines = read_file ($temp_file);
	$replace->($_) for @$lines; # run $replace on each game

   	write_file ($file, $lines);
   	unlink $temp_file;
}

my $file = "C:/Mine/perl/Football/data/EC.csv";
my $temp_file = "C:/Mine/perl/Football/data/EC temp.csv";

print "\nRewriting $file...";
copy $file, $temp_file;

my $lines = read_file ($temp_file);
for my $game (@$lines) {
	$game =~ s/K.*nn/Kings Lynn/g;
}
write_file ($file, $lines);
unlink $temp_file;

# End workaround for Kings Lynn

end comment

=cut

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
