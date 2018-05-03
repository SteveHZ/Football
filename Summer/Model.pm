package Summer::Model;

#	Summer::Model.pm 12/03/18

use lib 'C:/Mine/perl/Football';
use Summer::Summer_Data_Model;
use Football::Globals qw( @summer_leagues @summer_csv_leagues );
use Data::Dumper;

use Moo;
use namespace::clean;

extends 'Football::Model';
with 'Football::Roles::Football_IO_Role';

sub BUILD {
	my $self = shift;
	$self->{leagues} = [];
	$self->{league_names} = \@summer_leagues;
	$self->{csv_leagues} = \@summer_csv_leagues;

	$self->{model_name} = "Summer";
	$self->{path} = 'C:/Mine/perl/Football/data/Summer/';
	$self->{fixtures_file} = $self->{path}.'fixtures.csv';
	$self->{season_data} = $self->{path}.'season.json';
	$self->{teams_file} = $self->{path}.'teams.json';
#	$self->{results_file} = $self->{path}.'results.ods';
#	$self->{test_season_data} = 'C:/Mine/perl/Football/t/test_data/euro_season.json';
}

#	over-ride Football_IO_Role::update

sub update {
	my $self = shift;
	my $data_model = Summer::Summer_Data_Model->new ();
	my $games = {};

	for my $idx (0..$#{ $self->{csv_leagues} }) {
		my $csv_file = $self->{path}.$self->{csv_leagues}[$idx].'.csv';
		if (-e $csv_file) {
			print "\nUpdating $self->{league_names}[$idx]...";
			$games->{ $self->{league_names}[$idx] } = $data_model->read_csv ($csv_file);
		}
	}
	$self->write_json ($self->{season_data}, $games);
	print "\nWriting data...";
	return $games;
}

#	Not implemented by Summer::Model

sub do_favourites {};
sub do_head2head {}
sub do_league_places {}
sub fetch_goal_difference {}

1;
