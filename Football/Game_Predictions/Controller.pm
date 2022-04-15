package Football::Game_Predictions::Controller;

use Football::Game_Predictions::Model;
use Football::Game_Predictions::Recent_Model;

use Football::Game_Predictions::Views::UK;
use Football::Game_Predictions::Views::Euro;
use Football::Game_Predictions::Views::Summer;
use MyJSON qw(write_json);

use Moo;
use namespace::clean;

my $valid_types = sub { qr/season|recent/ };
has 'type' => (	is => 'ro',
				required => 1,
#				default => 'season',
				isa => sub { die "Invalid type : $_[0]" unless $_[0] =~ $valid_types->() },
);

has 'leagues' => (is => 'ro', required => 1);
has 'fixtures' => (is => 'ro', required => 1);
has 'model_name' => (is => 'ro', required => 1);
has 'model' => (is => 'ro');

sub BUILD {
    my $self = shift;
    my $dispatch = {
        'season' => sub { Football::Game_Predictions::Model->new (@_) },
        'recent' => sub { Football::Game_Predictions::Recent_Model->new (@_) },
    };
    $self->{model} = $dispatch->{ $self->{type} }->(
        fixtures => $self->{fixtures},
        leagues  => $self->{leagues},
    );
}

sub do_predictions {
    my $self = shift;

    my ($teams, $sorted) = $self->do_predict_models ();
    $self->do_predict_views ($teams, $sorted);
}

sub do_predict_models {
	my $self = shift;
    my $model = $self->{model};

    my $teams = $model->calc_goal_expect ();
    my $sorted = {
        expect => $model->sort_expect_data (),
        match_odds => $model->calc_match_odds ($self->{model_name}),
        skellam => $model->calc_skellam_dist (),
        over_under => $model->calc_over_under (),
    };
    $sorted->{data} = $model->save_expect_data ( $sorted->{expect}, $self->{model_name} );

	return ($teams, $sorted);
}

sub do_predict_views {
	my ($self, $teams, $sorted) = @_;

#   Define the view here instead of in a constructor to avoid
#   clobbering an existing spreadsheet during testing
    my $view = $self->get_view ($self->{model_name});

	$view->do_goal_expect ($self->{leagues}, $teams, $sorted);
	$view->do_match_odds ($sorted);
	$view->do_over_under ($sorted);
}

sub get_view {
    my ($self, $model_name) = @_;

    my $dispatch = {
        'UK'    => sub { return Football::Game_Predictions::Views::UK->new     (); },
        'Euro'  => sub { return Football::Game_Predictions::Views::Euro->new   (); },
        'Summer'=> sub { return Football::Game_Predictions::Views::Summer->new (); },
    };
    return $dispatch->{$model_name}->();
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
