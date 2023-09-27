#	fixtures_test2.pl 09/11/22
#	Originally written to figure out why Schalke 04 wasn't showing
#	Also trying to remove Women's football

use strict;
use warnings;
use Data::Dumper;

use Football::FIxtures::Model;

#	Need to ensure that both return statements work correctly

#my $day = "Sun"; my $date = "2023-01-29";
#my $day = "Sat" ; my $date = "2023-03-18";
#my $day = "Thur" ; my $date = "2023-03-23";
my $day = "Sat" ; my $date = "2023-03-25";


my $games = read_file ("C:/Mine/perl/Football/data/Euro/scraped/fixtures $date.txt",
					  { day => $day, date => $date} );
print Dumper $games;

# Adapted from Football::FIxtures::Model::read_file

sub read_file {
	my ($filename, $day) = @_;
	open my $fh, '<', $filename or die "Can't open $filename";
	chomp ( my $data = <$fh> );
	close $fh;

	my $model = Football::Fixtures::Model->new ();
	my $date = $model->as_date_month ($day->{date});

#	return $model->prepare (\$data, $day->{day}, $date);

	return $model->after_prepare (
		$model->prepare (\$data, $day->{day}, $date)
	);
}
