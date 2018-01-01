package Football::Reports::Base;

# 	Football::Reports::Base.pm 05/03/16, 04/05/16

use Moo;
use namespace::clean;

with 'Roles::MyJSON';

# Child classes need to set up $self->{hash}
# and optionally, $self->{json_file}

sub setup_results {
	return {
		home_win => 0,
		away_win => 0,
		draw => 0,
	};
}

sub write {
	my ($self, $leagues) = @_;

	$self->write_json ($self->{json_file}, $self->{hash});
	$self->write_report ($leagues);
}

sub get_result {
	my ($self, $home, $away) = @_;
	
	return 'H' if $home > $away;
	return 'A' if $home < $away;
	return 'D';
}

# To be implemented by child classes

sub setup {}
sub update {}
sub write_report {}
sub fetch_array {}
sub fetch_hash {}

1;
