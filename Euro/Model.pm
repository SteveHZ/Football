package Euro::Model;

#	Euro::Model.pm 26/06/17

use lib 'C:/Mine/perl/Football';
use Football::Globals qw( @euro_lgs @euro_csv_lgs );

use Moo;
use namespace::clean;

extends 'Football::Model';
with 'Football::Roles::Football_IO_Role';
#with 'Football::Roles::Rugby_IO_Role';

sub BUILD {
	my $self = shift;
	$self->{leagues} = [];
	$self->{league_names} = \@euro_lgs;
	$self->{csv_leagues} = \@euro_csv_lgs;
#	$self->{league_names} = \@summer_leagues;
#	$self->{csv_leagues} = \@summer_csv_leagues;

	$self->{model_name} = "Euro";
	$self->{path} = 'C:/Mine/perl/Football/data/Euro/';
	$self->{fixtures_file} = $self->{path}.'fixtures.csv';
	$self->{season_data} = $self->{path}.'season.json';
	$self->{teams_file} = $self->{path}.'teams.json';
#	$self->{results_file} = $self->{path}.'results.ods';
	$self->{test_season_data} = 'C:/Mine/perl/Football/t/test_data/euro_season.json';
}

=head
sub fetch_goal_difference {
	my ($self, $goal_diff_obj, $league_name, $goal_difference) = @_;
	return $goal_diff_obj->fetch_array ("Premier League", $goal_difference);
}
=cut

#	Not implemented by Euro::Model

sub do_favourites {};
sub do_head2head {}
sub do_league_places {}

1;
