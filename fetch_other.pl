#	fetch_other.pl 14-18/10/18
#	scrape Welsh and N Irish results from BBC
#	Use Oddsp.pl instead to retrieve odds

#BEGIN { $ENV{PERL_KEYWORD_PRODUCTION} = 1;}
#BEGIN { $ENV{PERL_KEYWORD_DELETEALL} = 1;}

use strict;
use warnings;

use Football::Results_Model;
use Football::Results_View;
use MyKeyword qw(PRODUCTION DELETEALL);
use Data::Dumper;

my $model = Football::Results_Model->new ();
my $view = Football::Results_View->new ();

my $out_path = 'C:/Mine/perl/Football/data/Euro';
my $in_path = $out_path.'/scraped';
my $leagues = [ qw(welsh-premier-league irish-premiership) ];

my $files = $model->get_pages ($leagues);
print "\n";

for my $league (keys (%$files)) {
	my @all_games = ();
	for my $file (@{ $files->{$league} } ) {
		my $filename = "$in_path/$file.txt";

		open my $fh, '<', $filename or die "Can't open $filename";
		chomp ( my $data = <$fh> );
		close $fh;

		my $games = $model->after_prepare (
			$model->prepare (\$data)
		);
		push @all_games, $games;
	}
	$view->write_csv ($out_path, $league, \@all_games);
}

DELETEALL {
	$model->delete_all ($in_path, $files);
}
