package Football::Favourites_Model;

use Moo;
use namespace::clean;

with 'Roles::MyJSON';

has 'hash' => ( is => 'ro' );
has 'json_file' => ( is => 'ro' );

my $path = 'C:/Mine/perl/Football/data/';
my $uk_file = $path.'favourites_history.json';
my $euro_file = $path.'euro_favourites_history.json';

my $update_favourites = 1;

sub BUILD {
	my ($self, $args) = @_;

	$self->{update} = ($update_favourites) ?
		$args->{update} : $update_favourites;
	$self->{json_file} = $args->{filename} eq "uk" ?
		$uk_file : $euro_file;
	$self->{history} = (-e $self->{json_file}) ?
		$self->read_json ($self->{json_file}) : [];
}

sub setup {
	return {
		stake => 0,
		fav_winnings => 0,
		under_winnings => 0,
		draw_winnings => 0,
	};
}

sub history {
	my $self = shift;
	if ($self->{update}) {
		push (@ {$self->{history} }, $self->{hash} );
		$self->write_json ($self->{json_file}, $self->{history});
	}
	return $self->{history};
}

sub update {
	my ($self, $league, $year, $results) = @_;
	$self->{hash}->{$league}->{$year} = $self->setup ();
	my $hashref = $self->{hash}->{$league}->{$year};
	
	for my $game (@$results) {
		$hashref->{stake} ++;
		if ($game->{result} eq 'D') {
			$hashref->{draw_winnings} += $game->{draw_odds};
		} elsif ($game->{home_odds} > $game->{away_odds}) {
			if ($game->{result} eq 'H'){
				$hashref->{under_winnings} += $game->{home_odds};
			} else {
				$hashref->{fav_winnings} += $game->{away_odds};
			}
		} else {
			if ($game->{result} eq 'A'){
				$hashref->{under_winnings} += $game->{away_odds};
			} else {
				$hashref->{fav_winnings} += $game->{home_odds};
			}
		}
	}
}

=pod

=head1 NAME

Favourites_Model.pm

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
