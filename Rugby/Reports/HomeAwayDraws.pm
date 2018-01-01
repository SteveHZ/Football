package Rugby::Reports::HomeAwayDraws;

# 	Rugby::Reports::HomeAwayDraws.pm 16/03/16
#	v1.1 07/05/17

use Rugby::Spreadsheets::Reports;
use Moo;
use namespace::clean;

extends 'Football::Reports::HomeAwayDraws';

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/Rugby/';
	return $path.'homes_aways_draws.json';
}

sub write_report {
	my $self = shift;
	
	my $writer = Rugby::Spreadsheets::Reports->new (report => "Homes Aways Draws");
	$writer->do_homeawaydraws ($self->{hash});
}

1;