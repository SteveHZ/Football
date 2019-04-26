package Football::Favourites;

use List::MoreUtils qw(each_array);
use Football::Globals qw( @league_names @csv_leagues );
use Football::Favourites_Model;
use Football::Favourites_Data_Model;
use Football::Favourites_View;

use Moo;
use namespace::clean;

has 'season' => (is => 'ro', required => 1);
has 'update' => (is => 'ro', required => 1);
has 'filename' => (is => 'ro', required => 1);

sub BUILD {
    my $self = shift;
    $self->{fav_model} = Football::Favourites_Model->new (update => $self->{update}, filename => $self->{filename});
    $self->{view} = Football::Favourites_View->new (state => 'current');
}

sub do_favourites {
    my $self = shift;

    my $hash = $self->{fav_model}->do_favourites ($self->{season});
    $self->{view}->do_favourites ($hash);
}

=pod

=head1 NAME

Football::Favourites.pm

=head1 SYNOPSIS

Controller for Favourites triad

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
