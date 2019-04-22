package Football::Favourites_View;

use Moo;
use namespace::clean;

use Football::Spreadsheets::Favourites;

sub BUILD {
	my ($self, $args) = @_;
	$self->{state} = $args->{state};

	if ($self->{state} eq 'previous') {
		$self->{by_year} = Football::Spreadsheets::Favourites->new (filename => 'by_year');
		$self->{by_league} = Football::Spreadsheets::Favourites->new (filename => 'by_league');
	} else {
		$self->{current} = Football::Spreadsheets::Favourites->new (filename => 'current');
	}
}

sub do_favourites {
	my ($self, $hash) = @_;
	$self->{current}->do_favourites ($hash);
}

sub show {
	my ($self, $hash, $leagues, $seasons) = @_;

	if ($self->{state} eq 'previous') {
		$self->{by_year}->show ($hash, $leagues, $seasons);
		$self->{by_league}->show ($hash, $leagues, $seasons);
	} else {
		$self->{current}->show ($hash, $leagues, $seasons);
	}
}

=pod

=head1 NAME

Football::Favourites_View.pm

=head1 SYNOPSIS

View for Favourites triad

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
