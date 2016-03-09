package Football::Reports::Base;

# 	Football::Reports::Base.pm 05/03/16

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

	write_json ($self->{json_file}, $self->{hash});
	$self->write_report ();
}

1;