package Football::Game_Predictions::Controller;

use Football::Game_Predictions::Model;
use Football::Game_Predictions::Views::UK;
use Football::Game_Predictions::Views::Euro;
use Football::Game_Predictions::Views::Summer;
use MyJSON qw(write_json);

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
    my $model = Football::Game_Predictions::Model->new (
        fixtures => $self->{fixtures},
        leagues  => $self->{leagues}
    );
    my $save_odds;

	my ($teams, $sorted) = $model->calc_goal_expect ();
	($sorted->{match_odds}, $save_odds) = $model->calc_match_odds ();
	$sorted->{skellam} = $model->calc_skellam_dist ();
	$sorted->{over_under} = $model->calc_over_under ();
    $sorted->{data} = $model->build_expect_data ( $sorted->{expect});

    my $filename = "C:/Mine/perl/Football/data/combine data/expect $self->{view_name}.json";
    write_json ($filename, $sorted->{data});
    $filename = "C:/Mine/perl/Football/data/match odds $self->{view_name}.json";
    write_json ($filename, $save_odds);

	return ($teams, $sorted);
}

sub do_predict_views {
	my ($self, $teams, $sorted) = @_;

#   Define the view here instead of in a constructor to avoid
#   clobbering an existing spreadsheet during testing
    my $view = $self->get_view ($self->{view_name});

	$view->do_goal_expect ($self->{leagues}, $teams, $sorted);
	$view->do_match_odds ($sorted);
	$view->do_over_under ($sorted);
}

sub get_view {
    my ($self, $view_name) = @_;

    my $dispatch = {
        'UK'    => sub { return Football::Game_Predictions::Views::UK->new     (); },
        'Euro'  => sub { return Football::Game_Predictions::Views::Euro->new   (); },
        'Summer'=> sub { return Football::Game_Predictions::Views::Summer->new (); },
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
