BEGIN { $ENV{PERL_KEYWORD_DEV} = 1; }

use MyHeader;
use Summer::Model;
use Summer::View;

my $model = Summer::Model->new;
my $view = Summer::View->new;
#my $model = Football::Model->new;
my $data = $model->quick_build ();
#print Dumper $data;

$view->fixtures ( $data->{by_league} );

$view->do_recent_goal_difference ( $model->do_recent_goal_difference ($data->{by_league}, $data->{leagues}) );
$view->do_goal_difference ( $model->do_goal_difference ($data->{by_league}, $data->{leagues}) );
$view->do_league_places ( $model->do_league_places ($data->{by_league}, $data->{leagues}) );
$view->do_head2head ( $model->do_head2head ($data->{by_league} ) );
$view->do_recent_draws ( $model->do_recent_draws ($data->{by_league} ) );
