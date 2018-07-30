package Football::Roles::Rugby_IO_Role;

use List::MoreUtils qw(firstidx);
use Date::Simple qw(today);
use Rugby::Rugby_Data_Model;

use Moo::Role;

requires qw(
	read_json write_json
	league_names csv_leagues
	model_name path fixtures_file season_data
);

#sub read_games {
#	my $self = shift;
#	my $args = { @_ };
#	my $update = exists $args->{update} ? $args->{update} : 0;

#	my $games = (-e $self->{season_data}) ?
#		$self->read_json ($self->{season_data}) : {};
#	$self->update ($games) if $update;
##die "\n\nFinished reading results"; # for the first few weeks of each season
#	return $games;
#}

sub update {
	my $self = shift;
	my $data_model = Rugby::Rugby_Data_Model->new ();
	my $games = {};

	for my $idx (0..$#{ $self->{league_names} }) {
		my $csv_file = $self->{path}.$self->{league_names}[$idx].'.csv';
		if (-e $csv_file) {
			print "\nUpdating $self->{league_names}[$idx]...";
			$games->{ $self->{league_names}[$idx] } = $data_model->read_archived ($csv_file);
		}
	}
	$self->write_json ($self->{season_data}, $games);
	print "\nWriting data...";
	return $games;
}

#sub update {
#	my ($self, $games) = @_;
#	my $data_model = Rugby::Rugby_Data_Model->new ();
#
#	$data_model->update ($games, $self->{results_file});
#	$self->write_json ($self->{season_data}, $games);
#	$self->do_backup ($games);
#}

#sub do_backup {
#	my ($self, $games) = @_;
#	
#	my $date = Date::Simple->new (today ());
#	my $backup_file = "C:/Mine/perl/Football/data/backups/".
#		$self->{model_name}." ".$date.".json";
#	$self->write_json ($backup_file, $games);
#}

sub get_fixtures {
	my $self = shift;
	my @fixtures = ();

	open (my $fh, '<', $self->{fixtures_file}) or die ("\n\nCan't find $self->{fixtures_file}");
	while (my $line = <$fh>) {
		chomp ($line);
		my ($date, $league, $home, $away) = split (',', $line);
		if ((my $idx = firstidx {$_ eq $league} @{ $self->{csv_leagues}} ) >= 0) {
			push (@fixtures, {
				date => $date,
				league_idx => $idx,
				league => $self->{league_names}[$idx],
				home_team => $home,
				away_team => $away,
			});
		}
	}
	close $fh;
	return \@fixtures;
}

1;
