package Football::Reports::LeaguePlaces;

# 	Football::Reports::LeaguePlaces.pm 05/03/16

use strict;
use warnings;

use MyJSON qw(read_json write_json);
use Football::Spreadsheets::Reports;

use parent 'Football::Reports::Base';

my $path = 'C:/Mine/perl/Football/data/';
my $json_file = $path.'league_places.json';

sub new {
	my ($class, $seasons) = @_;
	
	my $self = $class->SUPER::new ($json_file);
	if ($seasons) {
		$self->{hash} = $self->setup ();
	} else {
		$self->{hash} = read_json ($json_file);
	}
	bless $self, $class;
	return $self;
}

sub setup {
	my $self = shift;
	my $hash = {};
	for my $home (1..20) {
		for my $away (1..20) {
			next if ($home == $away);
			$hash->{$home}->{$away} = $self->setup_results ();
		}
	}
	return $hash;
}

sub update {
	my ($self, $teams, $game) = @_;

	my $result = $self->get_result ($game->{home_score}, $game->{away_score});
	my $home = $game->{home_team};
	my $away = $game->{away_team};
	my $home_pos = $teams->{$home}->{position};
	my $away_pos = $teams->{$away}->{position};

	if ($result eq 'H')		{ $self->{hash}->{$home_pos}->{$away_pos}->{home_win} ++; }
	elsif ($result eq 'A')	{ $self->{hash}->{$home_pos}->{$away_pos}->{away_win} ++; }
	else 					{ $self->{hash}->{$home_pos}->{$away_pos}->{draw} ++; }
}

sub write_report {
	my $self = shift;
	
	my $writer = Football::Spreadsheets::Reports->new ("League Places");
	$writer->do_league_places ($self->{hash});
}

sub fetch_array {
	my ($self, $home, $away) = @_;
	return [
		$self->{hash}->{$home}->{$away}->{home_win},
		$self->{hash}->{$home}->{$away}->{away_win},
		$self->{hash}->{$home}->{$away}->{draw},
	];
}

sub fetch_hash {
	my ($self, $home, $away) = @_;
	return \%{ $self->{hash}->{$home}->{$away} };
}

1;