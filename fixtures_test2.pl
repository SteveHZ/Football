#	fixtures_test2.pl 09/11/22
#	Written to figure out why Schalke 04 wasn't showing

use strict;
use warnings;
use Data::Dumper;

use Football::FIxtures::Model;

my $games = read_file ("C:/Mine/perl/Football/data/Euro/scraped/fixtures 2022-11-09.txt",
					  { day => "Wed", date => "20221109"} );
print Dumper $games;

# Adapted from Football::FIxtures::Model::read_file

sub read_file {
	my ($filename, $day) = @_;
	open my $fh, '<', $filename or die "Can't open $filename";
	chomp ( my $data = <$fh> );
	close $fh;

	my $model = Football::Fixtures::Model->new ();
	my $date = $model->as_date_month ($day->{date});
#	return $model->after_prepare (
		$model->prepare (\$data, $day->{day}, $date)
#	);
}

