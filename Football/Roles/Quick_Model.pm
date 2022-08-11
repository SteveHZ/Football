package Football::Roles::Quick_Model;

use Football::Game_Predictions::Controller;
use Football::Game_Predictions::Model;
use MyJSON qw(read_json);

use Moo::Role;

sub quick_predict {
	my $self = shift;
	my ($data, $stats) = $self->quick_build ();

	$self->{predict} = Football::Game_Predictions::Controller->new (
		fixtures => $stats->{by_match},
		leagues => $self->leagues,
		model_name => $self->model_name,
		type => 'season',
	);
	my ($teams, $sorted) = $self->{predict}->do_predict_models ($data->{by_match}, $self->leagues);
	$self->{sorted} = $sorted;
	return ($teams, $sorted, $stats);
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

sub build_data {
	my ($self, $args) = @_;

	my $games = (exists $args->{json})
		? read_json ($args->{json})
		: $self->read_games ();
	my $leagues = $self->build_leagues ($games);

	return {
		games => $games,
		leagues => $leagues,
		homes => $self->do_homes ($leagues),
		aways => $self->do_aways ($leagues),
		last_six => $self->do_last_six ($leagues),
	};
}

sub get_game_predictions_model {
	my $self = shift;
	my $gpm = Football::Game_Predictions::Model->new (
		fixtures => $self->{predict}->{fixtures},
		leagues => $self->{predict}->{leagues},
		expect_model => $self->{sorted}->{expect},
	);
	return $gpm;
}

# For calculating individual matches with game_odds.pl

sub quick_predict2 {
	my ($self, $fixtures) = @_;
	my ($data, $stats) = $self->quick_build2 ($fixtures);

	$self->{predict} = Football::Game_Predictions::Controller->new (
		fixtures => $stats->{by_match},
		leagues => $self->leagues,
		model_name => $self->model_name,
		type => 'season',
	);
	my ($teams, $sorted) = $self->{predict}->do_predict_models ($data->{by_match}, $self->leagues);
	$self->{sorted} = $sorted;
	return ($teams, $sorted, $stats);
}

sub quick_build2 {
	my ($self, $fixtures) = @_;
	my $data = $self->build_data ();
	my $stats = $self->do_fixtures ($fixtures);

	$self->do_recent_goal_difference ($stats->{by_league}, $self->leagues);
	$self->do_goal_difference ($stats->{by_league}, $self->leagues);
	$self->do_league_places ($stats->{by_league}, $self->leagues);
	$self->do_head2head ($stats->{by_league} );
	$self->do_recent_draws ($stats->{by_league} );
	return ($data, $stats);
}

=pod

=head1 NAME

Football::Roles::Quick_Model.pm

=head1 SYNOPSIS

Role used by Model.pm to enable quicker data building for writing tests.
Also used by game_odds.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
