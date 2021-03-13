package Football::Favourites::Model;

use Football::Favourites::Data_Model;
use Football::Globals qw( @league_names @csv_leagues );
use List::MoreUtils qw(each_array);

use Moo;
use namespace::clean;
with 'Roles::MyJSON';

has 'hash' => ( is => 'ro' );
has 'json_file' => ( is => 'ro' );

my $path = 'C:/Mine/perl/Football/data/';
my $fav_path = 'C:/Mine/perl/Football/data/favourites/';
my $uk_file = $path.'favourites_history.json';
my $euro_file = $path.'euro_favourites_history.json';

my $update_favourites = 1;

sub BUILD {
	my ($self, $args) = @_;

	$self->{update} = ($update_favourites) ?
		$args->{update} : $update_favourites;
	$self->{json_file} = $args->{filename} eq 'uk' ?
		$uk_file : $euro_file;
#*******************************************************************
	$self->{history} = (-e $self->{json_file}) ?
		$self->read_json ($self->{json_file}) : [];
}

sub do_favourites {
	my ($self, $year) = @_;

	my $data_model = Football::Favourites::Data_Model->new ();
	my $iterator = each_array ( @league_names, @csv_leagues );

	while ( my ($league, $csv_league) = $iterator->() ) {
		my $file_from = $path.$csv_league.'.csv';
		my $file_to = $fav_path.$league.'/'.$year.'.csv';

		my $data = $data_model->update_current ($file_from, $year);
		$data_model->write_current ($file_to, $data);
		$self->update ($league, $year, $data);
	}
	return {
		data => $self->hash (),
		history => $self->history (),
		leagues => \@league_names,
		year => $year,
	};
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
		if ($game->{home_odds}) {
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
}

=pod

=head1 NAME

Football::Favourites_Model.pm

=head1 SYNOPSIS

Model for Favourites triad

=head1 DESCRIPTION

=head1 AUTHOR

Steve Hope

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
