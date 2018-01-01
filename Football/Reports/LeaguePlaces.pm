package Football::Reports::LeaguePlaces;

# 	Football::Reports::LeaguePlaces.pm 05/03/16 - 13/04/16
#	v1.1 07/05/17

use List::MoreUtils qw(each_arrayref);
use Football::Spreadsheets::Reports;

use Moo;
use namespace::clean;

extends 'Football::Reports::Base';

has 'league_size' => ( is => 'ro');

sub BUILD {
	my ($self, $args) = @_;

	$self->{json_file} = $self->get_json_file ();
	if ($args->{leagues}) {
		$self->{hash} = $self->setup ($args->{leagues}, $args->{league_size});
	} else {
		$self->{hash} = $self->read_json ($self->{json_file});
	}
	$self->{league_size} = $args->{league_size};
}

sub get_json_file {
	my $path = 'C:/Mine/perl/Football/data/';
	return $path.'league_places.json';
}

sub setup {
	my ($self, $leagues, $league_size) = @_;
	my $hash = {};
	my $iterator = each_arrayref ($leagues, $league_size);
	while ( my ($league, $size) = $iterator->() ) {
		for my $home (1..$size) {
			for my $away (1..$size) {
				next if ($home == $away);
				$hash->{$league}->{$home}->{$away} = $self->setup_results ();
			}
		}
	}
	return $hash;
}

sub update {
	my ($self, $league, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_pos = $teams->{$home}->{position};
	my $away_pos = $teams->{$away}->{position};

	if ($result eq 'H')		{ $self->{hash}->{$league}->{$home_pos}->{$away_pos}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$league}->{$home_pos}->{$away_pos}->{away_win} ++; }
	else 					{ $self->{hash}->{$league}->{$home_pos}->{$away_pos}->{draw} ++; }
}

sub write_report {
	my ($self, $leagues) = @_;

	my $writer = Football::Spreadsheets::Reports->new (report => "League Places");
	$writer->do_league_places ($self->{hash}, $leagues, $self->{league_size});
}

sub fetch_array {
	my ($self, $league, $home, $away) = @_;
	return [
		$self->{hash}->{$league}->{$home}->{$away}->{home_win},
		$self->{hash}->{$league}->{$home}->{$away}->{away_win},
		$self->{hash}->{$league}->{$home}->{$away}->{draw},
	];
}

sub fetch_hash {
	my ($self, $league, $home, $away) = @_;
	return $self->{hash}->{$league}->{$home}->{$away};
}

1;
