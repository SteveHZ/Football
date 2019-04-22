package Football::Game_Predictions;

use Football::Game_Prediction_Models;
use Football::Game_Prediction_Views;

use Moo;
use namespace::clean;

has 'fixtures' => (is => 'ro', required => 1);
has 'leagues' => (is => 'ro', required => 1);

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

#   define view here instead of in a constructor to avoid clobbering an existing spreadsheet during testing
    my $view = Football::Game_Prediction_Views->new ();
	$view->do_goal_expect ($self->{leagues}, $teams, $sorted);
	$view->do_match_odds ($sorted);
	$view->do_over_under ($sorted);
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
