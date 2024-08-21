
# rl2024.pl 27/07/24- 10/08/24

use strict;
use warnings;
#use Data::Dumper;

sub read_line {
	my $game = shift;
	
	my @data = split ',', $game;
	return {
		date => $data [0],
		league => $data [1],
		home_team => $data [2],
		away_team => $data [3],
		home_spread => $data [4],
		away_spread => $data [4] * -1,
		home_odds => $data [5],
		away_odds => $data [6],
		home_score => $data [7],
		away_score => $data [8],
	};
}

sub beat_home_spread {
	my $game = shift;
	
	return  $game->{home_score} + $game->{home_spread}
			> $game->{away_score};
}

sub beat_away_spread {
	my $game = shift;
	
	return  $game->{away_score} + $game->{away_spread}
			> $game->{home_score};
}

sub do_home_spread {
	my $games = shift;
	my ($stake, $return) = (0,0);
	
	for my $game (@$games) {
		$stake ++;
		if (beat_home_spread ($game)) {
			$return += $game->{home_odds};
		}
	}
	print "\nHome Spread : stake = $stake return = $return";
}

sub do_away_spread {
	my $games = shift;
	my ($stake, $return) = (0,0);
	
	for my $game (@$games) {
		$stake ++;
		if (beat_away_spread ($game)) {
			$return += $game->{away_odds};
		}
	}
	print "\nAway Spread : stake = $stake return = $return";
}

sub do_negative_spread {
	my $games = shift;
	my ($stake, $return) = (0,0);
	
	for my $game (@$games) {
		$stake ++;
		if ($game->{home_spread} < 0 && beat_home_spread ($game)) {
			$return += $game->{home_odds};
		} elsif ($game->{away_spread} < 0 && beat_away_spread ($game)) {
			$return += $game->{away_odds};
		}
	}
	
	print "\nNegative Spread : stake = $stake return = $return";
}

sub do_positive_spread {
	my $games = shift;
	my ($stake, $return) = (0,0);
	
	for my $game (@$games) {
		$stake ++;
		if ($game->{home_spread} > 0 && beat_home_spread ($game)) {
			$return += $game->{home_odds};
		} elsif ($game->{away_spread} > 0 && beat_away_spread ($game)) {
			$return += $game->{away_odds};
		}
	}
	
	print "\nPositive Spread : stake = $stake return = $return\n";
}

sub positive_spread_favourites {
	my $games = shift;
	my ($stake, $return) = (0,0);
	
	for my $game (@$games) {
		if ($game->{home_spread} > 0
			&& ($game->{home_odds} < $game->{away_odds})) {
			$stake ++;
			if (beat_home_spread ($game)) {
				$return += $game->{home_odds};
			}
		} elsif ($game->{away_spread} > 0
				 && ($game->{away_odds} < $game->{home_odds})) {
			$stake ++;
			if (beat_away_spread ($game)) {
				$return += $game->{away_odds};
			}
		}
	}
	print "\nPositive Spread Favs : stake = $stake return = $return\n";
}

sub get_league {
	my ($league, $games) = @_;
	
	return [
		grep { $_->{league} eq $league } @$games
	];
}

my @games;

while ( my $line = <DATA> ) {
	chomp $line;
	push ( @games, read_line ($line) );
}

my $dispatch = [
	{ league => "SL",  games => get_league ("SL",  \@games) },
	{ league => "NRL", games => get_league ("NRL", \@games) },
	{ league => "CH",  games => get_league ("CH",  \@games) },
	{ league => "L1",  games => get_league ("L1",  \@games) },
	{ league => "ALL", games => \@games },
];

for my $league ( @$dispatch ) {
	print "\n$league->{league} :";
	do_home_spread ( $league->{games} );
	do_away_spread ( $league->{games} );

	print "\n";
	do_negative_spread ( $league->{games} );
	do_positive_spread ( $league->{games} );
	positive_spread_favourites ($league->{games} );
}

#print "\n\n";
#print "POSITIVE SPREAD FAVOURITES :";


#print "\nBEAT HOME SPREAD : \n";
#for my $game (@games) {
#	if (beat_home_spread ($game)) {
#		print "\n$game->{home_team} v $game->{away_team} spread = $game->{home_spread} score = $game->{home_score} - $game->{away_score}";
#	}
#}

#print "\n\nBEAT AWAY SPREAD : \n";
#for my $game (@games) {
#	if (beat_away_spread ($game)) {
#		print "\n$game->{home_team} v $game->{away_team} spread = $game->{away_spread} score = $game->{home_score} - $game->{away_score}";
#	}
#}

=begin comment


10/08/24,CH,Doncaster,Toulouse,16.5,1.83,1.83
11/08/24,CH,Batley,Swinton,26,6
11/08/24,CH,Bradford,Whitehaven,58,0
11/08/24,CH,Halifax,Barrow,38,12
11/08/24,CH,Widnes,Featherstone,0,8
11/08/24,CH,York,Dewsbury,54,12
11/08/24,L1,Midlands,Workington,34,22
11/08/24,L1,North Wales,Keighley,16
11/08/24,L1,Oldham,Newcastle,
=end comment
=cut

__DATA__
25/07/24,SL,Huddersfield,Leeds,1.5,2,1.8,6,34
26/07/24,SL,Hull KR,London,-37.5,1.8,2,40,16
26/07/24,SL,Leigh,St Helens,1.5,2,1.8,46,4
26/07/24,SL,Wigan,Warrington,-5.5,1.8,2,4,40
26/07/24,NRL,NZ,Wests,-12.5,1.91,1.91,28,16
26/07/24,NRL,Parramatta,Melbourne,-16.5,1.91,1.91,14,32
27/07/24,NRL,Brisbane,Canterbury,-8.5,1.95,1.8,16,41
27/07/24,NRL,N Queens,Cronulla,-1.5,1.82,2,30,22
27/07/24,NRL,Sydney,Manly,-6.5,1.91,1.91,34,30
27/07/24,SL,Salford,Castleford,-7.5,1.8,2,30,22
27/07/24,SL,Catalans,Hull,-15.5,1.8,2,24,16
28/07/24,NRL,St George,Penrith,11.5,1.91,1.91,10,46
28/07/24,NRL,Dolpins,Gold Coast,-5.5,1.87,1.95,14,21
28/07/24,NRL,Canberra,Sth Sydney,-3.5,1.87,1.95,32,12
01/08/24,NRL,Wests,Nth Queens,10.5,1.91,1.91,30,48
01/08/24,SL,Castleford,Leigh,10.5,1.8,2,10,20
01/08/24,SL,Wigan,Huddersfield,-15.5,1.8,2,26,14
02/08/24,NRL,NZ,Parramatta,-13.5,1.87,1.95,20,30
02/08/24,NRL,Dolphins,Sydney,11.5,2,1.82,34,40
02/08/24,SL,Warrington,Hull KR,-8.5,1.9,1.9,4,18
03/08/24,NRL,Gold Coast,Brisbane,4.5,1.91,1.91,46,18
03/08/24,NRL,Melbourne,St George,-19.5,1.82,2,16,18
03/08/24,NRL,Cronulla,Sth Sydney,-10.5,1.91,1.91,20,6
03/08/24,SL,Hull,St Helens,1.5,2,1.8,6,46
03/08/24,SL,Salford,Leeds,1.5,1.9,1.9,22,16
04/08/24,NRL,Penrith,Newcastle,-18.5,1.95,1.87,22,14
04/08/24,NRL,Canterbury,Canberra,-8.5,1.95,1.87,22,18
04/08/24,SL,London,Catalans,22.5,1.9,1.9,12,10
04/08/24,CH,Barrow,Bradford,10.5,1.8,1.9,24,24
04/08/24,CH,Dewsbury,Wakefield,40.5,1.8,1.9,16,42
04/08/24,CH,Featherstone,Batley,-12.5,1.9,1.8,24,16
04/08/24,CH,Halifax,York,-1.5,1.9,1.8,38,18
04/08/24,CH,Sheffield,Doncaster,-16.5,1.9,1.8,22,20
04/08/24,CH,Whitehaven,Widnes,10.5,1.8,1.9,12,24
04/08/24,L1,Keighley,Newcastle,-56.5,1.9,1.8,72,12
04/08/24,L1,Oldham,Midlands,-32.5,1.9,1.8,32,0
04/08/24,L1,Rochdale,Cornwall,-32.5,1.9,1.8,46,32
04/08/24,L1,Workington,North Wales,-10.5,1.9,1.8,24,28
06/08/24,SL,Wigan,Leigh,-8.5,2,1.8,28,6
08/08/24,NRL,Sth Sydney,Melbourne,16.5,1.95,1.87,16,28
08/08/24,SL,St Helens,Salford,-10.5,1.9,1.9,17,16
09/08/24,NRL,Gold Coast,Cronulla,-2.5,1.91,1.91,0,44
09/08/24,NRL,Parramatta,Penrith,16.5,1.91,1.91,34,36
09/08/24,SL,Huddersfield,Catalans,-4.5,1.9,1.9,22,23
09/08/24,SL,Hull KR,Castleford,-19.5,1.8,2,36,6
10/08/24,NRL,Canberra,Manly,3.5,1.95,1.87,24,46
10/08/24,NRL,Nth Queens,Brisbane,-6.5,1.95,1.87,18,42
10/08/24,NRL,St George,Canterbury,3.5,1.91,1.91,10,28
10/08/24,L1,Cornwall,Hunslet,16.5,1.8,1.9,26,33
10/08/24,SL,Leeds,Wigan,6.5,1.9,1.9,30,6
11/08/24,NRL,Dolphins,NZ,-7.5,1.82,2,34,32
11/08/24,NRL,Newcastle,Wests,-9.5,1.91,1.91,34,18
11/08/24,SL,Leigh,Hull,-19.5,1.8,2,42,12
11/08/24,SL,London,Warrington,24.5,1.9,1.9,22,36
