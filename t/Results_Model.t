#	Results_Model.t 04/08/18

use strict;
use warnings;
use Test::More tests => 2;
use Rugby::Results_Model;
use Data::Dumper;

my @games = ();
while (my $line = <DATA>) {
	chomp $line;
	push @games, $line;
}
close DATA;
print Dumper @games;

my $model = Rugby::Results_Model->new;
my $sorted = $model->sort_games (\@games);
print Dumper [ $sorted ];

subtest 'sort_games' => sub {
	is (@$sorted[0], '07/07/18,Toronto Wolfpack,Sheffield,34,10', '07/07/18,Toronto Wolfpack,Sheffield,34,10');
	is (@$sorted[1], '07/07/18,Toulouse Olympique,London Broncos,20,20', '07/07/18,Toulouse Olympique,London Broncos,20,20');
	is (@$sorted[2], '08/07/18,Batley,Leigh Centurions,12,30', '08/07/18,Batley,Leigh Centurions,12,30');
};

subtest 'get_date_cmp' => sub {
	my $date = '06/05/66';
	is ($model->get_date_cmp (\$date), '660506', 'get_date_cmp 06/05/66'); 
};

__DATA__
29/07/18,Halifax,Rochdale Hornets,38,6
29/07/18,Batley,Swinton,40,18
29/07/18,Barrow Raiders,London Broncos,6,72
28/07/18,Toulouse Olympique,Dewsbury Rams,44,18
28/07/18,Toronto Wolfpack,Featherstone Rovers,12,30
22/07/18,Sheffield,Barrow Raiders,28,10
22/07/18,Leigh Centurions,Swinton,50,24
22/07/18,Halifax,Toulouse Olympique,19,14
22/07/18,Featherstone Rovers,London Broncos,7,14
22/07/18,Dewsbury Rams,Batley,23,20
21/07/18,Toronto Wolfpack,Rochdale Hornets,52,10
15/07/18,Sheffield,Dewsbury Rams,30,28
15/07/18,Swinton,Featherstone Rovers,4,60
15/07/18,London Broncos,Halifax,20,18
15/07/18,Barrow Raiders,Toulouse Olympique,6,72
14/07/18,Rochdale Hornets,Leigh Centurions,32,54
14/07/18,Toronto Wolfpack,Batley,64,18
08/07/18,Rochdale Hornets,Swinton,28,26
08/07/18,Halifax,Featherstone Rovers,34,20
08/07/18,Dewsbury Rams,Barrow Raiders,22,20
08/07/18,Batley,Leigh Centurions,12,30
07/07/18,Toulouse Olympique,London Broncos,20,20
07/07/18,Toronto Wolfpack,Sheffield,34,10

=head
sub first_sort_games {
	my $games = shift;
	my @new_games = ();
	
	for my $game (@$games) {
		my @data = split ',', $game;
		push @new_games, {
			date => $data[0],
			home_team => $data[1],
			away_team => $data[2],
			home_score => $data[3],
			away_score => $data[4],
			date_cmp => get_date_cmp ($data[0]),
		};
	}
	my @temp = sort {
		$a->{date_cmp} <=> $b->{date_cmp}
		or $a->{home_team} cmp $b->{home_team}
	} @new_games;
	
	my @sorted = ();
	for my $game (@temp) {
		push @sorted, "$game->{date},$game->{home_team},$game->{away_team},$game->{home_score},$game->{away_score}";
	}
	return \@sorted;
}
=cut
