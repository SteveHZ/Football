#	fixtures.pl 05-14/05/18

BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}

use strict;
use warnings;

use Football::Fixtures_Model;
use Football::Fixtures_View;
use MyKeyword qw(PRODUCTION DELETEALL);

my $model = Football::Fixtures_Model->new ();
my $view = Football::Fixtures_View->new ();
my $week = $model->get_week ();

my $path = "C:/Mine/perl/Football/data/Euro/scraped/";
my @all_games = ();

PRODUCTION {
	$model->get_pages ($week);
}
for my $day (@$week) {
	my $filename = "$path/fixtures $day->{date}.txt";
	open my $fh, "<", $filename or die "Can't open $filename";
	chomp ( my $data = <$fh> );
	close $fh;

	my $dmy = $model->as_dmy ($day->{date});
	my $games = $model->after_prepare ( $model->prepare (\$data, $day->{day}, $dmy) );

	push @all_games, @$games;
	$view->dump ($games);
}
my $out_file = "$path/fixtures_week.csv";
$view->write_csv ($out_file, \@all_games);

DELETEALL {
	$model->delete_all ($path, $week);
}
