package Football::Roles::Football_IO_Role;

use List::MoreUtils qw(firstidx);
use Football::Football_Data_Model;
use MyKeyword qw(TESTING); # for model.t

use Moo::Role;

requires qw(
	read_json write_json
	league_names csv_leagues
	path fixtures_file season_data
	test_fixtures_file
);

sub update {
	my $self = shift;
	my $data_model = Football::Football_Data_Model->new ();
	my $games = {};

	for my $idx (0..$#{ $self->{csv_leagues} }) {
		my $csv_file = $self->{path}.$self->{csv_leagues}[$idx].'.csv';
		if (-e $csv_file) {
			print "\nUpdating $self->{league_names}[$idx]...";
			$games->{ $self->{league_names}[$idx] } = $data_model->update ($csv_file);
		}
	}
	$self->write_json ($self->{season_data}, $games);
	print "\nWriting data...";
	return $games;
}

sub get_fixtures {
	my $self = shift;

	my $fixtures_file = $self->{fixtures_file};
	TESTING { $fixtures_file = $self->{test_fixtures_file}; }
	my @fixtures = ();

	open (my $fh, '<', $fixtures_file) or die ("\n\nCan't find $fixtures_file");
	while (my $line = <$fh>) {
		chomp ($line);
		my ($date, $league, $home, $away) = split (',', $line); # my fixtures files
		if ((my $idx = firstidx {$_ eq $league} @{ $self->{csv_leagues}} ) >= 0) {
			push (@fixtures, {
				league_idx => $idx,
				league => $self->{league_names}[$idx],
				date => $date,
				home_team => $home,
				away_team => $away,
			});
		}
	}
	close $fh;
	return \@fixtures;
}

#	test_season_data

# 	moved this into Shared Model as rugby now reads a similar file

#sub read_games {
#	my ($self, $update) = @_;
#	my $games;

#	TESTING {
#		print "    Reading test data from $self->{test_season_data}\n";
#		$games = $self->read_json ($self->{test_season_data});
#	} elsif ($update) {
#		$games = $self->update ();
#	} else {
#		$games = (-e $self->{season_data}) ?
#			$self->read_json ($self->{season_data}) : {};
#	}
#	return $games;
#}

1;
