package Football::Team;

#	Football::Team.pm 03/02/16 - 12/03/16, Mouse version 04/05/16
#	Moo version 01/10/16

use List::Util qw(max);
use MyIterators qw(make_iterator);
use Football::Globals qw($default_stats_size);

use Moo;
use namespace::clean;

has 'stats_size' => (is => 'ro', default => $default_stats_size);
has 'games' => ( is => 'ro' );

sub add {
	my ($self, $game) = @_;
	push @{ $self->{games} }, $game;
}

sub iterator {
    my $self = shift;
    return () unless defined $self->{games};
    return make_iterator ($self->{games});
}

sub get_homes {
	my ($self, $num_games) = @_;
	$num_games //= $self->{stats_size};
	return $self->get_stats ('H', $num_games);
}

sub get_aways {
	my ($self, $num_games) = @_;
	$num_games //= $self->{stats_size};
	return $self->get_stats ('A', $num_games);
}

sub most_recent {
	my ($self, $num_games) = @_;
	$num_games //= $self->{stats_size};
	return $self->get_most_recent ($num_games);
}

sub get_stats {
	my ($self, $home_away, $num_games) = @_;
	my @results = ();

	my @list = grep {$_->{home_away} eq $home_away} @{ $self->{games} };
	my $full_stats = $self->splice_array (\@list, $num_games);

	push @results, $_->{result} for @$full_stats;
	return (\@results, $full_stats);
}

sub get_most_recent {
	my ($self, $num_games) = @_;
	my @results = ();

	my @list = @{ $self->{games} };
	my $full_stats = $self->splice_array (\@list, $num_games);

	push @results, $_->{result} for @$full_stats;
	return (\@results, $full_stats);
}

sub splice_array {
	my ($self, $arrayref, $num_games) = @_;

	my $last = scalar @$arrayref;
	my $start = max (0, $last - $num_games);
	my $games = ($start == 0) ? $last : $num_games;

	my @spliced = splice (@$arrayref, $start, $games);
	return \@spliced;
}

=pod

=head1 NAME

Team.pm

=head1 SYNOPSIS

Used by predict.pl

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
