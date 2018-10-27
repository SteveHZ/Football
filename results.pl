#	results.pl 04-05/06/18, 07/07/18, 18/10/18

#BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
#BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}

use strict;
use warnings;

use Rugby::Results_Model;
use Rugby::Results_View;
use MyKeyword qw(PRODUCTION DELETEALL);
use Data::Dumper;

my $model = Rugby::Results_Model->new ();
my $view = Rugby::Results_View->new ();

my $out_path = 'C:/Mine/perl/Football/data/Rugby';
my $in_path = $out_path.'/scraped';

my $all_games = {};
my @leagues = (
	{ name => 'Super League', site => 'https://www.bbc.co.uk/sport/rugby-league/super-league/results' },
	{ name => 'Championship', site => 'https://www.bbc.co.uk/sport/rugby-league/championship/results' },
	{ name => 'League One',	  site => 'https://www.bbc.co.uk/sport/rugby-league/league-one/results' },
	{ name => 'NRL',          site => 'https://www.bbc.co.uk/sport/rugby-league/nrl-premiership/results' },
);

PRODUCTION {
	$model->get_pages (\@leagues);
}

for my $league (@leagues) {
	my $filename = "$in_path/$league->{name}.txt";
	open my $fh, '<', $filename or die "Can't open $filename";
	chomp ( my $data = <$fh> );
	close $fh;

	my $games = $model->after_prepare (
		$model->prepare (\$data)
	);
	print Dumper $games;
	$all_games->{ $league->{name} } = $games;
}

$view->write_csv ($out_path, $all_games);

#DELETEALL {
#	$model->delete_all ($path, $week);
#}
