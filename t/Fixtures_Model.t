#	Fixtures_Model.t 16/06/18, 11/09/18

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; } # for Fixtures_Model:transform_hash

use Test2::V0;
plan 7;

use lib "C:/Mine/perl/Football";
use Football::Fixtures::Model;
use Football::Globals qw(@csv_leagues @summer_csv_leagues @euro_csv_lgs);
use MyJSON qw(read_json write_json);

my $model = Football::Fixtures::Model->new ();
my $date = '2018-06-16';

subtest 'constructor' => sub {
	plan 1;
	isa_ok ($model, ['Football::Fixtures::Model'], '$model');
};

subtest 'as_dmy' => sub {
	plan 2;
	is ($model->as_dmy ($date), '16/06/18', '16/06/18 is');
	isnt ($model->as_dmy ($date), '16/6/18', "16/6/18 isn't");
};


subtest 'as_date_month' => sub {
	plan 2;
	is ($model->as_date_month ($date), '16/06', '16/06 is');
	isnt ($model->as_dmy ($date), '16/6', "16/6 isn't");
};

subtest 'do_foreign chars' => sub {
	plan 1;
	no utf8;
    my $str = 'äåöøÖéüæ';
	$model->do_foreign_chars (\$str);
    is ($str, "aaooOeuae", 'foreign chars ok');
};

subtest 'transform_hash' => sub {
	plan 4;
	my $files = $model->transform_hash ({
	    uk      => \@csv_leagues,
	    euro    => \@euro_csv_lgs,
	    summer  => \@summer_csv_leagues,
	});

    is ($files->{E0}, 'uk', 'uk ok');
	is ($files->{NRW}, 'summer', 'summer ok');
    isnt ($files->{EC}, 'summer', 'EC not summer ok');
    is ($files->{WL}, 'euro', 'euro ok');
};

subtest 'postponed chars' => sub {
	plan 1;
    my $filename = "C:/Mine/perl/Football/t/test data/fixtures/fixtures 2019-10-12 MATCH POSTPONED INTERNATIONAL CALL UPS2.txt";
    my $day = {
        day => 'Sa',
        date => '2019-10-12',
    };
    my $games = $model->read_file ($filename, $day);
	use Data::Dumper; print Dumper $games->{uk};
# is(1,1,'dummy');
    unlike ($games->{uk}->[2], qr/POxford/, 'postponed chars removed');
};

subtest 'get_week' => sub {
	plan 1;
	my $week = $model->get_week ({ days => 7, forwards => 1, include_today => 0 });
#	use Data::Dumper; print Dumper $week;
	is (scalar @$week, 7, 'get_week');
};

=head
TODO: {
subtest 'prepare' => sub {
	plan tests => 1;
	local $TODO = 'prepare test not fixed yet !!';
	my $all_games = {};
	my $data = {};
	my $week = read_json ('c:/mine/perl/football/t/test data/fixtures/dates.json');

	for my $day (@$week) {
		my $filename = "c:/mine/perl/football/t/test data/fixtures/before_prepare $day->{date}.txt";
		open my $fh, '<', $filename or die "Can't open $filename";
		chomp ( $data->{$day} = <$fh> );
		close $fh;
	}
	my $after = read_json ('c:/mine/perl/football/t/test data/fixtures/after_prepare.json');

	for my $day (@$week) {
		my $dataref = $data->{$day};
		my $date = $model->as_date_month ($day->{date});
		my $games = $model->after_prepare (
			$model->prepare (\$dataref, $day->{day}, $date)
		);
		for my $key (keys %$games) {
			push @{ $all_games->{$key} }, $_ for (@{ $games->{$key} });
		}
	}
	write_json ('c:/mine/perl/football/t/test data/fixtures/actual.json', $all_games);
	cmp_deeply ($all_games, $after, 'compare data');
};
}
=cut
