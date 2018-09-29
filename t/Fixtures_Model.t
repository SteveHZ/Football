#	Fixtures_Model.t 16/06/18, 11/09/18

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; } # for Fixtures_Model:transform_hash

use strict;
use warnings;
use Test::More tests => 5;

use lib "C:/Mine/perl/Football";
use Football::Fixtures_Model;
use Football::Globals qw(@csv_leagues @summer_csv_leagues @euro_csv_lgs);

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

subtest 'do_foreign chars' => sub {
	plan tests => 1;
    my $str = 'AAäåAA/öÖøæ';
	$model->do_foreign_chars (\$str);
    is ($str, 'AAaaAA oOoae', 'foreign chars ok');
};

#subtest 'contains' => sub {
#	plan tests => 2;
#	my @list = qw(Steve Linda Zappy);
#	is ($model->contains (\@list, 'Zappy'), 1, 'contains');
#	is ($model->contains (\@list, 'Hopey'), 0, 'doesn\'t contain');
#};

subtest 'transform_hash' => sub {
    plan tests => 3;
	my $files = $model->transform_hash ({
	    uk      => \@csv_leagues,
	    euro    => \@euro_csv_lgs,
	    summer  => \@summer_csv_leagues,
	});

    is ($files->{E0}, 'uk', 'uk ok');
    isnt ($files->{EC}, 'summer', 'EC not summer ok');
    is ($files->{WL}, 'euro', 'euro ok');
};
