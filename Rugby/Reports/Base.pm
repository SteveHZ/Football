package Rugby::Reports::Base;

# 	Rugby::Reports::Base.pm 05/03/16
#	all this is old code, before adding leagues
# 	prob dont need this class at all
#	just inherit from football base ??

use strict;
use warnings;

use MyJSON qw(read_json write_json);

sub new {
	my ($class, $json_file) = @_;
	
	my $self = {
		json_file => $json_file,
	};
	bless $self, $class;
	return $self;
}

sub setup_results {
	return {
		home_win => 0,
		away_win => 0,
		draw => 0,
	};
}

sub get_result {
	my ($self, $home, $away) = @_;
	
	return 'H' if $home > $away;
	return 'A' if $home < $away;
	return 'D';
}

sub write {
	my $self = shift;
print "\nIn write";
	write_json ($self->{json_file}, $self->{hash});
	$self->write_report ();
}

# To be implemented by child classes

sub setup {}
sub update {}
sub write_report {}
sub fetch_array {}
sub fetch_hash {}

1;