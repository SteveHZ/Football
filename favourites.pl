#!	C:/Strawberry/perl/bin

#	DO NOT USE 27/05/17
#	previous is done from create_reports.pl
#	current is done from predict.pl

# 	favourites.pl 12-19/07/16, 07-11/08/16

#	only use -p option at end of seasons
#	update current_season variable first
#	predict.pl updates current season (-c)

use strict;
use warnings;

use Getopt::Long qw(GetOptions);
use List::MoreUtils qw(each_arrayref);

use Football::Favourites_Model;
use Football::Favourites_View;
use Football::Favourites_Data_Model;

my $last_season = 2016;
my $current_season = $last_season + 1;
my $seasons = [ 2010...$last_season ];

my $path = 'C:/Mine/perl/Football/data/favourites/';
my $current_path = 'C:/Mine/perl/Football/data/';

my $csv_leagues = [ "E0", "E1", "E2", "E3", "EC", "SC0", "SC1", "SC2", "SC3" ];
my $leagues = [	"Premier League", "Championship", "League One", "League Two", "Conference",
				"Scots Premier", "Scots Championship", "Scots League One", "Scots League Two",
];

main ();

sub main {
	my ($previous, $current) = get_cmdline ();

	if (! ($previous || $current)) {
		die "Usage : perl favourites.pl \noptions -p (previous) or -c (current)";
	}

	my $state = ($previous) ? "previous" : "current";
	my $model = Football::Favourites_Model->new (filename => "uk");
	my $view = Football::Favourites_View->new (state => $state);

	if ($previous) {
		do_previous ($model, $view, $leagues, $seasons);
	} else {
		do_current ($model, $view, $leagues, $current_season);
	}
}

sub get_cmdline {
	my ($previous, $current);

	GetOptions (
		'previous|p' => \$previous,
		'current|c' => \$current,
	) or die "Usage perl favourites.pl \noptions -p (previous) or -c (current)";

	return ($previous, $current);
}

sub do_previous {
	my ($model, $view, $leagues, $seasons) = @_;
	my $data_model = Football::Favourites_Data_Model->new ();

	for my $league (@$leagues) {
		for my $year (@$seasons) {
			my $file = $path.$league.'/'.$year.'.csv';
			my $data = $data_model->update ($file);
			$model->update ($league, $year, $data);
		}
	}	
	$view->show ($model->hash (), $leagues, $seasons);
}

sub do_current {
	my ($model, $view, $leagues, $year) = @_;
	my $data_model = Football::Favourites_Data_Model->new ();
	my $iterator = each_arrayref ( $leagues, $csv_leagues );

	while ( my ($league, $csv_league) = $iterator->() ) {
		my $file_from = $current_path.$csv_league.'.csv';
		my $file_to = $path.$league.'/'.$year.".csv";

		my $data = $data_model->update_current ($file_from, $csv_league);
		$data_model->write_current ($file_to, $data);
		$model->update ($league, $year, $data);
	}	
	$view->show ($model->hash (), $leagues, [ $year ]);
}
