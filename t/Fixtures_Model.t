#	Fixtures_Model.t 16/06/18

use strict;
use warnings;
use Test::More tests => 3;

use lib "C:/Mine/perl/Football";
use Football::Fixtures_Model;

my $model = Football::Fixtures_Model->new ();
my $date = '2018-06-16';

subtest 'constructor' => sub {
	plan tests => 1;
	isa_ok ($model, 'Football::Fixtures_Model', '$model');
};

subtest 'as_dmy' => sub {
	plan tests => 2;
	is ($model->as_dmy ($date), '16/06/18', '16/06/18 is');
	isnt ($model->as_dmy ($date), '16/6/18', "16/6/18 isn't");
};

subtest 'as_date_month' => sub {
	plan tests => 2;
	is ($model->as_date_month ($date), '16/06', '16/06 is');
	isnt ($model->as_dmy ($date), '16/6', "16/6 isn't");
};
