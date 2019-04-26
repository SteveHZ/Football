package Football::Game_Predictions;

use Football::Game_Prediction_Models;
use Football::Game_Predictions::UK;
use Football::Game_Predictions::Euro;
use Football::Game_Predictions::Summer;

use Moo;
use namespace::clean;

has 'fixtures' => (is => 'ro', required => 1);
has 'leagues' => (is => 'ro', required => 1);
has 'view_name' => (is => 'ro', required => 1);

sub do_predictions {
    my $self = shift;

    my ($teams, $sorted) = $self->do_predict_models ();
    $self->do_predict_views ($teams, $sorted);
}

sub do_predict_models {
	my $self = shift;
    my $model = Football::Game_Prediction_Models->new (
        fixtures => $self->{fixtures}, leagues => $self->{leagues}
    );

	my ($teams, $sorted) = $model->calc_goal_expect ();
	$sorted->{match_odds} = $model->calc_match_odds ();
	$sorted->{skellam} = $model->calc_skellam_dist ();
	$sorted->{over_under} = $model->calc_over_under ();

	return ($teams, $sorted);
}

sub do_predict_views {
	my ($self, $teams, $sorted) = @_;
#   define view here instead of in a constructor to avoid
#   clobbering an existing spreadsheet during testing
    my $view = $self->build_view ($self->{view_name});

	$view->do_goal_expect ($self->{leagues}, $teams, $sorted);
	$view->do_match_odds ($sorted);
	$view->do_over_under ($sorted);
}

sub build_view {
    my ($self, $view_name) = @_;

    my $dispatch = {
        'UK'    => sub { return Football::Game_Predictions::UK->new     (); },
        'Euro'  => sub { return Football::Game_Predictions::Euro->new   (); },
        'Summer'=> sub { return Football::Game_Predictions::Summer->new (); },
    };
    return $dispatch->{$view_name}->();
}

=pod

=head1 NAME

Football::Game_Predictions.pm

=head1 SYNOPSIS

Controller for Game_Predictions triad, called from predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
