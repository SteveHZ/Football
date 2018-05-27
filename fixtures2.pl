#	fixtures2.pl 19-20/05/18

use strict;
use warnings;

use Football::Fixtures_Globals qw( fixture_rename );

my @paths = (
	{
		in_file  => "C:/Mine/perl/Football/data/Euro/scraped/fixtures_uk.csv",
		out_file => "C:/Mine/perl/Football/data/fixtures.csv",
	},
	{
		in_file  => "C:/Mine/perl/Football/data/Euro/scraped/fixtures_euro.csv",
		out_file => "C:/Mine/perl/Football/data/Euro/fixtures.csv",
	},
	{
		in_file  => "C:/Mine/perl/Football/data/Euro/scraped/fixtures_summer.csv",
		out_file => "C:/Mine/perl/Football/data/Summer/fixtures.csv",
	},
);

for my $path (@paths) {
	if (-e $path->{in_file}) {
		open my $fh_in,  '<', $path->{in_file}  or die "Can't find $path->{in_file}";
		open my $fh_out, '>', $path->{out_file} or die "Can't open $path->{out_file} for writing";

		while (my $line = <$fh_in>) {
			chomp $line;
			my @data = split ',', $line;
			$data[2] = fixture_rename ($data[2]);	# home team
			$data[3] = fixture_rename ($data[3]);	# away team

			print $fh_out $data[1].','.$data[2].','.$data[3]."\n";
		}
		close $fh_in;
		close $fh_out;
		print "\nFinished writing $path->{out_file}";
	}
}
