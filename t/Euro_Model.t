#	Model.t 01/05/16
#	Euro::Model.t 10/08/17, 07/11/17

use Test2::V0;
plan 2;

use lib "C:/Mine/perl/Football";
use Euro::Model;

my $model = Euro::Model->new ();

subtest 'constructor' => sub {
	plan 2;
	my $games = $model->read_games ();
	my $leagues = $model->build_leagues ($games);

	isa_ok ($model, ['Euro::Model'], '$model');
	isa_ok (@$leagues [0], ['Football::League'], '@$leagues[0]');
};

# Shared Model
subtest 'get_league_idx' => sub {
	plan 4;
	is ($model->get_league_idx ('German League'), 0, 'German idx 0');
	is ($model->get_league_idx ('Spanish League'), 1, 'Spanish idx 1');
	is ($model->get_league_idx ('Italian League'), 2, 'Italian idx 2');
	is ($model->get_league_idx ('French League'), 3, 'French idx 3');
};
