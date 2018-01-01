package Rugby::Reports::LeaguePlaces;

# 	Rugby::Reports::LeaguePlaces.pm 05/03/16
#	v1.1 07/05/17

use Rugby::Spreadsheets::Reports;
use Moo;
use namespace::clean;

extends 'Football::Reports::LeaguePlaces';

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/Rugby/';
	return $path.'league_places.json';
}

sub write_report {
	my ($self, $leagues) = @_;
	
	my $writer = Rugby::Spreadsheets::Reports->new (report => "League Places");
	$writer->do_league_places ($self->{hash}, $leagues, $self->{league_size});
}

1;