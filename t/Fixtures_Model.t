#	Fixtures_Model.t 16/06/18, 11/09/18

BEGIN { $ENV{PERL_KEYWORD_TESTING} = 1; } # for Fixtures_Model:transform_hash

use strict;
use warnings;
use Test::More tests => 6;
use Test::Deep;
#use utf8;
#use Data::Dumper;

use lib "C:/Mine/perl/Football";
use Football::Fixtures_Model;
use Football::Globals qw(@csv_leagues @summer_csv_leagues @euro_csv_lgs);
use MyJSON qw(read_json write_json);
use MyKeyword qw(TESTING);

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
    my $str = 'äåöøÖéüæ';
	$model->do_foreign_chars (\$str);
    is ($str, 'aaooOeuae', 'foreign chars ok');
};

subtest 'transform_hash' => sub {
    plan tests => 4;
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

subtest 'prepare' => sub {
	plan tests => 1;
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
#	my ($ok, $stack) = cmp_details ($all_games, $after);
#my $reason = deep_diag($stack) unless $ok;
};

#subtest 'contains' => sub {
#	plan tests => 2;
#	my @list = qw(Steve Linda Zappy);
#	is ($model->contains (\@list, 'Zappy'), 1, 'contains');
#	is ($model->contains (\@list, 'Hopey'), 0, 'doesn\'t contain');
#};
