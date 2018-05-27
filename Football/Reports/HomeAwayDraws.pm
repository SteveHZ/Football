package Football::Reports::HomeAwayDraws;

# 	Football::Reports::HomeAwayDraws.pm 16/03/16 - 13/04/16
#	v1.1 07/05/17

use Moo;
use namespace::clean;

use Football::Spreadsheets::Reports;

extends 'Football::Reports::Base';

sub BUILD {
	my ($self, $args) = @_;

	$self->{json_file} = $self->get_json_file ();
	if ($args->{leagues}) {
		$self->{hash} = $self->setup ($args->{leagues}, $args->{seasons});
	} else {
		$self->{hash} = $self->read_json ($self->{json_file});
	}
}

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/';
	return $path.'homes_aways_draws.json';
}

sub setup {
	my ($self, $leagues, $seasons) = @_;
	my $hash = {};
	for my $league (@$leagues) {
		for my $season (@ { $seasons->{$league} }) {
			$hash->{$league}->{$season} = $self->setup_results ();
		}
	}
	return $hash;
}

sub update {
	my ($self, $league, $teams, $game, $season) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});

	if ($result eq 'H')		{ $self->{hash}->{$league}->{$season}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$season}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$season}->{draw} ++; }
}

sub write_report {
	my ($self, $leagues) = @_;
	
	my $writer = Football::Spreadsheets::Reports->new (report => "Homes Aways Draws");
	$writer->do_homeawaydraws ($self->{hash}, $leagues);
}

sub fetch_array {
	my ($self, $league, $season) = @_;
	return [
		$self->{hash}->{$league}->{$season}->{home_win},
		$self->{hash}->{$league}->{$season}->{away_win},
		$self->{hash}->{$league}->{$season}->{draw},
	];
}

sub fetch_hash {
	my ($self, $league, $season) = @_;
	return \%{ $self->{hash}->{$league}->{$season} };
}

1;
