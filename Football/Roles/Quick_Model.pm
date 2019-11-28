package Football::Roles::Quick_Model;

use Football::Game_Predictions::Controller;
use MyJSON qw(read_json);

use Moo::Role;

sub build_data {
	my ($self, $args) = @_;
	my $games;

	if (exists $args->{json}) {
		$games = read_json ($args->{json});
	} else {
		$games = $self->read_games ();
	}
	my $leagues = $self->build_leagues ($games);

	return {
		games => $games,
		leagues => $leagues,
		homes => $self->do_homes ($leagues),
		aways => $self->do_aways ($leagues),
		last_six => $self->do_last_six ($leagues),
	};
}

sub quick_build {
	my $self = shift;
	my $data = $self->build_data ();
	my $stats = $self->do_fixtures ($self->get_fixtures ());

	$self->do_recent_goal_difference ($stats->{by_league}, $self->leagues);
	$self->do_goal_difference ($stats->{by_league}, $self->leagues);
	$self->do_league_places ($stats->{by_league}, $self->leagues);
	$self->do_head2head ($stats->{by_league} );
	$self->do_recent_draws ($stats->{by_league} );
	return ($data, $stats);
}

sub quick_predict {
	my $self = shift;
	my ($data, $stats) = $self->quick_build ();

	my $predict = Football::Game_Predictions::Controller->new (
		fixtures => $stats->{by_match},
		leagues => $self->leagues,
		view_name => $self->model_name
	);
	my ($teams, $sorted) = $predict->do_predict_models ($data->{by_match}, $self->leagues);
	return ($teams, $sorted);
}

=pod

=head1 NAME

Football::Roles::Quick_Model.pm

=head1 SYNOPSIS

Role used by Model.pm to enable quicker data building for writing tests.

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
