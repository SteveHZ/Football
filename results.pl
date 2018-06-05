#	results.pl 04-05/06/18

#BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
#BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}

use strict;
use warnings;

use Football::Results_Model;
use Football::Fixtures_View;
use MyKeyword qw(PRODUCTION DELETEALL);
use Data::Dumper;

my $model = Football::Results_Model->new ();
my $view = Football::Fixtures_View->new ();
my $week = $model->get_reverse_week (3);

my $path = "C:/Mine/perl/Football/data/Euro/scraped/";
my @all_games = ();

PRODUCTION {
	my $site = "https://www.bbc.co.uk/sport/football/scores-fixtures";
	$model->get_pages ($site, $week);
}

for my $day (@$week) {
	my $filename = "$path/fixtures $day->{date}.txt";
	open my $fh, '<', $filename or die "Can't open $filename";
	chomp ( my $data = <$fh> );
	close $fh;

	my $dmy = $model->as_dmy ($day->{date});
	my $games = $model->after_prepare ( 
		$model->prepare (\$data), $day->{day}, $dmy );

	push @all_games, @$games;
	$view->dump ($games);
}

my $out_file = "$path/results_week.csv";
$view->write_csv ($out_file, \@all_games);

DELETEALL {
	$model->delete_all ($path, $week);
}
