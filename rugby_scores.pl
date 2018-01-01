#!	C:/Strawberry/perl/bin

#	rugby_scores.pl 26-27/09/16

use strict;
use warnings;

use Rugby::Model;
use MyJSON qw(write_json);

my $path = 'C:/Mine/perl/Football/data/Rugby/';
my $season_data = $path.'season.json';

main ();

sub main {
	my $model = Rugby::Model->new ();
	my ($home, $away);
	
	my $games = $model->read_games ();
	my $fixtures = $model->get_fixtures ();
	for my $game (@$fixtures) {
		my $league = $game->{league};
		do {
			print "\n$game->{date} $league : $game->{home_team} v $game->{away_team} : ";
			my $score = <STDIN>;
			($home, $away) = parse_score ($score);
		} while ($home < 0);
		
		print "Score : $home - $away";

		push ( @{ $games->{$league} }, {
			date => $game->{date},
			home_team => $game->{home_team},
			home_score => $home,
			away_team => $game->{away_team},
			away_score => $away,
		});
	}
	print "\n\nFull list of results :";
	for my $game (@$fixtures) {
		print "\n$game->{league} $game->{date} : $game->{home_team} $game->{home_score} $game->{away_team} $game->{away_score}";
	}
	write_json ($season_data, $games);
}

sub parse_score {
	my $score = shift;
	return ($1, $2) if $score =~ /(\d+)[-.](\d+)/;
	return -1;
}
