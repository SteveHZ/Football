#	Model.t 01/05/16
#	Euro::Model.t 10/08/17, 07/11/17

use strict;
use warnings;
use Test::More tests => 2;

use lib "C:/Mine/perl/Football";
use Euro::Model;

my $model = Euro::Model->new ();

subtest 'constructor' => sub {
	plan tests => 3;

	my $games = $model->read_games ();
	my $leagues = $model->build_leagues ($games);

	isa_ok ($model, 'Euro::Model', '$model');
	isa_ok ($games, 'HASH', '$games');
	isa_ok (@$leagues [0], 'Football::League', '@$leagues[0]');
};

# Shared Model
subtest 'get_league_idx' => sub {
	plan tests => 3;

	is ($model->get_league_idx ('German'), 0, 'German idx 0');
	is ($model->get_league_idx ('Italian'), 2, 'Italian idx 2');
	is ($model->get_league_idx ('N Irish'), 4, 'N Irish idx 4');
}
