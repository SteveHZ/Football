package Football::Reports::Favourites;

# 	favourites.pl 12-19/07/16, 07-11/08/16
#	favourites.pm 27/05/17

use Football::Favourites::Model;
use Football::Favourites::View;
use Football::Favourites::Data_Model;

use Moo;
use namespace::clean;

my $path = 'C:/Mine/perl/Football/data/favourites/';

sub BUILD {
	my ($self, $args) = @_;
	my $model = Football::Favourites::Model->new (filename => "uk");
	my $view = Football::Favourites::View->new (state => "previous");
	do_previous ($model, $view, $args->{leagues}, $args->{seasons});
}

sub do_previous {
	my ($model, $view, $leagues, $seasons) = @_;
	my $data_model = Football::Favourites::Data_Model->new ();

	for my $league (@$leagues) {
		for my $year (@$seasons) {
			my $file = $path.$league.'/'.$year.'.csv';
			my $data = $data_model->update ($file);
			$model->update ($league, $year, $data);
		}
	}
	$view->show ($model->hash (), $leagues, $seasons);
}

1;
